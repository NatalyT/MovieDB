//
//  MovieSearch.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 04.06.26.
//

import Foundation

private enum Constants {
    static let debounceNanoseconds: UInt64 = 300_000_000
    static let minimumSearchLength = 1
}

protocol MovieSearching {
    var onResultsChanged: (([Movie]) -> Void)? { get set }
    func search(query: String)
    func cancel()
}

@MainActor
final class MovieSearch: MovieSearching {

    // MARK: - Callbacks

    var onResultsChanged: (([Movie]) -> Void)?

    // MARK: - Private Properties

    private let searchMovies: SearchMoviesUseCase
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(searchMovies: SearchMoviesUseCase) {
        self.searchMovies = searchMovies
    }

    // MARK: - Search

    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty, trimmed.count >= Constants.minimumSearchLength else {
            cancel()
            onResultsChanged?([])
            return
        }

        debounceAPISearch(query: trimmed)
    }

    func cancel() {
        searchTask?.cancel()
        searchTask = nil
    }

    // MARK: - Private

    private func debounceAPISearch(query: String) {
        searchTask?.cancel()

        searchTask = Task {
            try? await Task.sleep(nanoseconds: Constants.debounceNanoseconds)
            guard !Task.isCancelled else { return }

            do {
                let result = try await searchMovies.execute(query: query, page: 1)
                guard !Task.isCancelled else { return }
                onResultsChanged?(result.movies)
            } catch {
                onResultsChanged?([])
            }
        }
    }
}

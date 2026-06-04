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

@MainActor
final class MovieSearch {

    // MARK: - Callbacks

    var onSuggestionsChanged: (([MovieSuggestion], Bool) -> Void)?

    // MARK: - Private Properties

    private let repository: MoviesRepository
    private let localItems: () -> [MovieCardViewData]
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(repository: MoviesRepository, localItems: @escaping () -> [MovieCardViewData]) {
        self.repository = repository
        self.localItems = localItems
    }

    // MARK: - Search

    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty, trimmed.count >= Constants.minimumSearchLength else {
            cancel()
            onSuggestionsChanged?([], false)
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
                let result = try await repository.search(query: query, page: 1)
                guard !Task.isCancelled else { return }

                let apiSuggestions = result.movies.map { mapToSuggestion($0) }

                if apiSuggestions.isEmpty {
                    let local = localSuggestions(for: query)
                    onSuggestionsChanged?(local, local.isEmpty)
                } else {
                    onSuggestionsChanged?(apiSuggestions, false)
                }
            } catch {
                let local = localSuggestions(for: query)
                onSuggestionsChanged?(local, local.isEmpty)
            }
        }
    }

    private func localSuggestions(for query: String) -> [MovieSuggestion] {
        localItems()
            .filter { $0.title.localizedCaseInsensitiveContains(query) }
            .map { MovieSuggestion(id: $0.id, title: $0.title, releaseDateText: $0.releaseDateText) }
    }

    private func mapToSuggestion(_ movie: Movie) -> MovieSuggestion {
        let dateText = DateFormatter.displayString(from: movie.releaseDate)
        return MovieSuggestion(id: movie.id, title: movie.title, releaseDateText: dateText)
    }
}

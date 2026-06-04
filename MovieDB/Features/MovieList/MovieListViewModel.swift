//
//  MovieListViewModel.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation
import Combine

private enum Constants {
    static let paginationThreshold = 5
    static let debounceNanoseconds: UInt64 = 300_000_000
    static let minimumSearchLength = 1
}

@MainActor
final class MovieListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var state: MovieListViewState = .loading
    @Published var searchQuery = ""
    @Published private(set) var suggestions: [MovieSuggestion] = []
    @Published private(set) var showNoResults = false

    // MARK: - Private Properties

    private let repository: MoviesRepository
    private var items: [MovieCardViewData] = []
    private var page = 1
    private var totalPages = 1
    private var isLoading = false
    private var searchTask: Task<Void, Never>?

    private var isFirstPage: Bool { page == 1 }

    // MARK: - Init

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    // MARK: - Popular Movies

    func loadInitial() {
        loadMore()
    }

    func loadMoreIfNeeded(currentItem: MovieCardViewData) {
        guard searchQuery.isEmpty else { return }
        guard let index = items.firstIndex(where: { $0.id == currentItem.id }) else { return }

        let thresholdIndex = items.count - Constants.paginationThreshold
        if index >= thresholdIndex {
            loadMore()
        }
    }

    func refresh() {
        page = 1
        items = []
        totalPages = 1
        isLoading = false
        searchQuery = ""
        cancelSearch()
        loadMore()
    }

    func retryLoadMore() {
        loadMore()
    }

    private func loadMore() {
        guard !isLoading, page <= totalPages else { return }
        isLoading = true

        if isFirstPage {
            state = .loading
        } else {
            state = .loaded(MovieListLoadedState(
                items: items,
                isLoadingMore: true,
                loadMoreError: nil
            ))
        }

        Task {
            do {
                let result = try await repository.popular(page: page)
                let existingIDs = Set(items.map(\.id))
                let newItems = result.movies
                    .filter { !existingIDs.contains($0.id) }
                    .map { mapToViewData($0) }
                items.append(contentsOf: newItems)
                totalPages = result.totalPages
                page += 1

                if items.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(MovieListLoadedState(
                        items: items,
                        isLoadingMore: false,
                        loadMoreError: nil
                    ))
                }
            } catch {
                if isFirstPage {
                    state = .error(ErrorMapping.mapToAlert(error))
                } else {
                    state = .loaded(MovieListLoadedState(
                        items: items,
                        isLoadingMore: false,
                        loadMoreError: ErrorMapping.mapToAlert(error)
                    ))
                }
            }
            isLoading = false
        }
    }

    private func mapToViewData(_ movie: Movie) -> MovieCardViewData {
        let dateText = movie.releaseDate.map { DateFormatter.displayDate.string(from: $0) } ?? ""
        let posterURL = movie.posterPath.flatMap { ImageURL.url(path: $0, size: .w185) }

        return MovieCardViewData(
            id: movie.id,
            title: movie.title,
            releaseDateText: dateText,
            posterURL: posterURL
        )
    }

    // MARK: - Movie Search

    func searchQueryChanged() {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)

        guard !query.isEmpty, query.count >= Constants.minimumSearchLength else {
            cancelSearch()
            suggestions = []
            showNoResults = false
            return
        }

        showNoResults = false
        debounceAPISearch(query: query)
    }

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
                    suggestions = local
                    showNoResults = local.isEmpty
                } else {
                    suggestions = apiSuggestions
                    showNoResults = false
                }
            } catch {
                let local = localSuggestions(for: query)
                suggestions = local
                showNoResults = local.isEmpty
            }
        }
    }

    private func localSuggestions(for query: String) -> [MovieSuggestion] {
        items
            .filter { $0.title.localizedCaseInsensitiveContains(query) }
            .map { MovieSuggestion(id: $0.id, title: $0.title, releaseDateText: $0.releaseDateText) }
    }

    private func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
    }

    private func mapToSuggestion(_ movie: Movie) -> MovieSuggestion {
        let dateText = movie.releaseDate.map { DateFormatter.displayDate.string(from: $0) } ?? ""
        return MovieSuggestion(id: movie.id, title: movie.title, releaseDateText: dateText)
    }

    // MARK: - Detail View

    func makeDetailViewModel(for movieID: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieID: movieID, repository: repository)
    }
}

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
}

@MainActor
final class MovieListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var state: MovieListViewState = .loading
    @Published var searchQuery = ""
    @Published private(set) var suggestions: [MovieSuggestion] = []
    @Published private(set) var showNoResults = false

    // MARK: - Private Properties

    private let getPopularMovies: GetPopularMoviesUseCase
    private let repository: MoviesRepository
    private var search: MovieSearching
    private var items: [MovieCardViewData] = []
    private var page = 1
    private var totalPages = 1
    private var isLoading = false

    private var isFirstPage: Bool { page == 1 }

    // MARK: - Init

    init(getPopularMovies: GetPopularMoviesUseCase, search: MovieSearching, repository: MoviesRepository) {
        self.getPopularMovies = getPopularMovies
        self.search = search
        self.repository = repository

        self.search.onResultsChanged = { [weak self] movies in
            self?.handleSearchResults(movies)
        }
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
        search.cancel()
        suggestions = []
        showNoResults = false
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
                let result = try await getPopularMovies.execute(page: page)
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
        let dateText = DateFormatter.displayString(from: movie.releaseDate)
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
        search.search(query: searchQuery)
    }

    private func handleSearchResults(_ movies: [Movie]) {
        if movies.isEmpty {
            let local = localSuggestions(for: searchQuery)
            suggestions = local
            showNoResults = local.isEmpty && !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
        } else {
            suggestions = movies.map { mapToSuggestion($0) }
            showNoResults = false
        }
    }

    private func localSuggestions(for query: String) -> [MovieSuggestion] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        return items
            .filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
            .map { MovieSuggestion(id: $0.id, title: $0.title, releaseDateText: $0.releaseDateText) }
    }

    private func mapToSuggestion(_ movie: Movie) -> MovieSuggestion {
        let dateText = DateFormatter.displayString(from: movie.releaseDate)
        return MovieSuggestion(id: movie.id, title: movie.title, releaseDateText: dateText)
    }

    // MARK: - Detail

    func makeDetailViewModel(for movieID: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieID: movieID, getMovieDetail: DefaultGetMovieDetailUseCase(repository: repository), repository: repository)
    }
}

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
    private let searchMovies: SearchMoviesUseCase
    private let repository: MoviesRepository
    private lazy var search: MovieSearch = {
        let search = MovieSearch(
            searchMovies: searchMovies,
            localItems: { [weak self] in self?.items ?? [] }
        )
        search.onSuggestionsChanged = { [weak self] suggestions, noResults in
            self?.suggestions = suggestions
            self?.showNoResults = noResults
        }
        return search
    }()
    private var items: [MovieCardViewData] = []
    private var page = 1
    private var totalPages = 1
    private var isLoading = false

    private var isFirstPage: Bool { page == 1 }

    // MARK: - Init

    init(getPopularMovies: GetPopularMoviesUseCase, searchMovies: SearchMoviesUseCase, repository: MoviesRepository) {
        self.getPopularMovies = getPopularMovies
        self.searchMovies = searchMovies
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

    // MARK: - Detail

    func makeDetailViewModel(for movieID: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieID: movieID, getMovieDetail: DefaultGetMovieDetailUseCase(repository: repository), repository: repository)
    }
}

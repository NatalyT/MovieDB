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

    @Published private(set) var state: MovieListViewState = .loading

    private let repository: MoviesRepository
    private var items: [MovieCardViewData] = []
    private var page = 1
    private var totalPages = 1
    private var isLoading = false

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    // MARK: - Factory

    func makeDetailViewModel(for movieID: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieID: movieID, repository: repository)
    }

    // MARK: - Loading

    func loadInitial() {
        loadMore()
    }

    func loadMoreIfNeeded(currentItem: MovieCardViewData) {
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
        loadMore()
    }

    func retry() {
        refresh()
    }

    func retryLoadMore() {
        loadMore()
    }

    // MARK: - Private

    private var isFirstPage: Bool { page == 1 }

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

}

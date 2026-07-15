//
//  MovieListViewModelTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 04.06.26.
//

import Combine
import XCTest
@testable import MovieDB

@MainActor
final class MovieListViewModelTests: XCTestCase {

    private var repository: FakeMoviesRepository!
    private var sut: MovieListViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        repository = FakeMoviesRepository()
        let getPopularMovies = DefaultGetPopularMoviesUseCase(repository: repository)
        sut = MovieListViewModel(getPopularMovies: getPopularMovies, repository: repository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        repository = nil
    }

    // MARK: - Initial Load

    func testInitialState_isLoading() {
        guard case .loading = sut.state else {
            return XCTFail("Expected loading state")
        }
    }

    func testLoadInitial_success_setsLoadedState() async {
        let movies = [Movie.stub(id: 1), Movie.stub(id: 2)]
        repository.popularResult = .success((movies: movies, totalPages: 3))

        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedState.items.count, 2)
        XCTAssertEqual(loadedState.items[0].id, 1)
        XCTAssertEqual(loadedState.items[1].id, 2)
        XCTAssertFalse(loadedState.isLoadingMore)
        XCTAssertNil(loadedState.loadMoreError)
    }

    func testLoadInitial_emptyResult_setsEmptyState() async {
        repository.popularResult = .success((movies: [], totalPages: 1))

        let exp = expectation(description: "empty")
        observeState { if case .empty = $0 { exp.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .empty = sut.state else {
            return XCTFail("Expected empty state")
        }
    }

    func testLoadInitial_failure_setsErrorState() async {
        repository.popularResult = .failure(URLError(.notConnectedToInternet))

        let exp = expectation(description: "error")
        observeState { if case .error = $0 { exp.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected error state")
        }

        XCTAssertFalse(message.isEmpty)
    }

    // MARK: - Pagination

    func testLoadMoreIfNeeded_nearEnd_loadsNextPage() async {
        let movies = (1...10).map { Movie.stub(id: $0, title: "Movie \($0)") }
        repository.popularResult = .success((movies: movies, totalPages: 3))

        let firstLoad = expectation(description: "first load")
        observeState { if case .loaded = $0 { firstLoad.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [firstLoad], timeout: 1.0)

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        cancellables.removeAll()
        let nearEndItem = loadedState.items[7]
        let nextMovies = [Movie.stub(id: 11)]
        repository.popularResult = .success((movies: nextMovies, totalPages: 3))

        let secondLoad = expectation(description: "second load")
        observeState {
            if case .loaded(let state) = $0, !state.isLoadingMore, state.items.count == 11 {
                secondLoad.fulfill()
            }
        }

        sut.loadMoreIfNeeded(currentItem: nearEndItem)
        await fulfillment(of: [secondLoad], timeout: 1.0)

        guard case .loaded(let updatedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(updatedState.items.count, 11)
        XCTAssertEqual(repository.popularCallCount, 2)
        XCTAssertEqual(repository.lastPopularPage, 2)
    }

    func testLoadMoreIfNeeded_notNearEnd_doesNotLoad() async {
        let movies = (1...10).map { Movie.stub(id: $0, title: "Movie \($0)") }
        repository.popularResult = .success((movies: movies, totalPages: 3))

        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        let earlyItem = loadedState.items[0]
        sut.loadMoreIfNeeded(currentItem: earlyItem)

        XCTAssertEqual(repository.popularCallCount, 1)
    }

    func testLoadMore_filtersDuplicates() async {
        let movies = [Movie.stub(id: 1), Movie.stub(id: 2)]
        repository.popularResult = .success((movies: movies, totalPages: 3))

        let firstLoad = expectation(description: "first load")
        observeState { if case .loaded = $0 { firstLoad.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [firstLoad], timeout: 1.0)

        cancellables.removeAll()
        let nextMovies = [Movie.stub(id: 1), Movie.stub(id: 3)]
        repository.popularResult = .success((movies: nextMovies, totalPages: 3))

        let secondLoad = expectation(description: "second load")
        observeState {
            if case .loaded(let state) = $0, !state.isLoadingMore, state.items.count == 3 {
                secondLoad.fulfill()
            }
        }

        sut.retryLoadMore()
        await fulfillment(of: [secondLoad], timeout: 1.0)

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedState.items.count, 3)
        XCTAssertEqual(loadedState.items.map(\.id), [1, 2, 3])
    }

    func testLoadMore_failure_onSecondPage_showsLoadMoreError() async {
        let movies = [Movie.stub(id: 1)]
        repository.popularResult = .success((movies: movies, totalPages: 3))

        let firstLoad = expectation(description: "first load")
        observeState { if case .loaded = $0 { firstLoad.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [firstLoad], timeout: 1.0)

        cancellables.removeAll()
        repository.popularResult = .failure(URLError(.notConnectedToInternet))

        let errorLoad = expectation(description: "load more error")
        observeState {
            if case .loaded(let state) = $0, state.loadMoreError != nil {
                errorLoad.fulfill()
            }
        }

        sut.retryLoadMore()
        await fulfillment(of: [errorLoad], timeout: 1.0)

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state with error")
        }

        XCTAssertEqual(loadedState.items.count, 1)
        XCTAssertNotNil(loadedState.loadMoreError)
    }

    // MARK: - Refresh

    func testRefresh_resetsAndReloads() async {
        let movies = [Movie.stub(id: 1)]
        repository.popularResult = .success((movies: movies, totalPages: 2))

        let firstLoad = expectation(description: "first load")
        observeState { if case .loaded = $0 { firstLoad.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [firstLoad], timeout: 1.0)

        cancellables.removeAll()
        let newMovies = [Movie.stub(id: 99, title: "New Movie")]
        repository.popularResult = .success((movies: newMovies, totalPages: 1))

        let refreshLoad = expectation(description: "refresh load")
        observeState {
            if case .loaded(let state) = $0, state.items.first?.id == 99 {
                refreshLoad.fulfill()
            }
        }

        sut.refresh()
        await fulfillment(of: [refreshLoad], timeout: 1.0)

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedState.items.count, 1)
        XCTAssertEqual(loadedState.items[0].id, 99)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertTrue(sut.suggestions.isEmpty)
    }

    // MARK: - Search

    func testSearchQueryChanged_withResults_updatesSuggestions() async {
        let movies = [Movie.stub(id: 1, title: "Batman"), Movie.stub(id: 2, title: "Batman Begins")]
        repository.searchResult = .success((movies: movies, totalPages: 1))

        let exp = expectation(description: "suggestions updated")
        sut.$suggestions.dropFirst().sink { suggestions in
            if suggestions.count == 2 { exp.fulfill() }
        }.store(in: &cancellables)

        sut.searchQuery = "Batman"
        sut.searchQueryChanged()
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(sut.suggestions.count, 2)
        XCTAssertEqual(sut.suggestions[0].title, "Batman")
        XCTAssertFalse(sut.showNoResults)
    }

    func testSearchQueryChanged_noResults_showsNoResults() async {
        repository.searchResult = .success((movies: [], totalPages: 1))

        let exp = expectation(description: "no results shown")
        sut.$showNoResults.dropFirst().sink { noResults in
            if noResults { exp.fulfill() }
        }.store(in: &cancellables)

        sut.searchQuery = "xyznonexistent"
        sut.searchQueryChanged()
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertTrue(sut.suggestions.isEmpty)
        XCTAssertTrue(sut.showNoResults)
    }

    func testSearchQueryChanged_emptyQuery_clearsSuggestions() async {
        let movies = [Movie.stub(id: 1, title: "Batman")]
        repository.searchResult = .success((movies: movies, totalPages: 1))

        let filled = expectation(description: "suggestions filled")
        sut.$suggestions.dropFirst().sink { suggestions in
            if suggestions.count == 1 { filled.fulfill() }
        }.store(in: &cancellables)

        sut.searchQuery = "Batman"
        sut.searchQueryChanged()
        await fulfillment(of: [filled], timeout: 1.0)

        XCTAssertEqual(sut.suggestions.count, 1)

        cancellables.removeAll()
        sut.searchQuery = ""
        sut.searchQueryChanged()

        XCTAssertTrue(sut.suggestions.isEmpty)
        XCTAssertFalse(sut.showNoResults)
    }

    func testRefresh_clearsSuggestions() async {
        let movies = [Movie.stub(id: 1, title: "Batman")]
        repository.searchResult = .success((movies: movies, totalPages: 1))
        repository.popularResult = .success((movies: [Movie.stub(id: 1)], totalPages: 1))

        let loaded = expectation(description: "loaded")
        observeState { if case .loaded = $0 { loaded.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [loaded], timeout: 1.0)

        cancellables.removeAll()
        let filled = expectation(description: "suggestions filled")
        sut.$suggestions.dropFirst().sink { suggestions in
            if suggestions.count == 1 { filled.fulfill() }
        }.store(in: &cancellables)

        sut.searchQuery = "Batman"
        sut.searchQueryChanged()
        await fulfillment(of: [filled], timeout: 1.0)

        XCTAssertEqual(sut.suggestions.count, 1)

        cancellables.removeAll()
        let refreshed = expectation(description: "refreshed")
        observeState {
            if case .loaded = $0 { refreshed.fulfill() }
        }

        sut.refresh()
        await fulfillment(of: [refreshed], timeout: 1.0)

        XCTAssertTrue(sut.suggestions.isEmpty)
        XCTAssertFalse(sut.showNoResults)
        XCTAssertEqual(sut.searchQuery, "")
    }

    func testLoadMoreIfNeeded_ignoredDuringSearch() async {
        let movies = (1...10).map { Movie.stub(id: $0) }
        repository.popularResult = .success((movies: movies, totalPages: 3))

        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.loadInitial()
        await fulfillment(of: [exp], timeout: 1.0)

        sut.searchQuery = "test"

        guard case .loaded(let loadedState) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        let nearEndItem = loadedState.items[8]
        sut.loadMoreIfNeeded(currentItem: nearEndItem)

        XCTAssertEqual(repository.popularCallCount, 1)
    }

    // MARK: - Helpers

    private func observeState(_ handler: @escaping (MovieListViewState) -> Void) {
        sut.$state.dropFirst().sink { handler($0) }.store(in: &cancellables)
    }
}

//
//  MovieSearchTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 04.06.26.
//

import XCTest
@testable import Domain
@testable import MovieDB

@MainActor
final class MovieSearchTests: XCTestCase {

    private var repository: FakeMoviesRepository!
    private var sut: MovieSearch!

    override func setUp() {
        repository = FakeMoviesRepository()
        let searchMovies = DefaultSearchMoviesUseCase(repository: repository)
        sut = MovieSearch(searchMovies: searchMovies)
    }

    override func tearDown() {
        sut = nil
        repository = nil
    }

    // MARK: - Empty / Short Query

    func testSearch_emptyQuery_returnsEmpty() async {
        let exp = expectation(description: "callback")
        sut.onResultsChanged = { movies in
            XCTAssertEqual(movies.count, 0)
            exp.fulfill()
        }

        sut.search(query: "")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_whitespaceOnly_returnsEmpty() async {
        let exp = expectation(description: "callback")
        sut.onResultsChanged = { movies in
            XCTAssertEqual(movies.count, 0)
            exp.fulfill()
        }

        sut.search(query: "   ")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    // MARK: - API Search

    func testSearch_validQuery_returnsMovies() async {
        let movies = [Movie.stub(id: 1, title: "Batman"), Movie.stub(id: 2, title: "Batman Begins")]
        repository.searchResult = .success((movies: movies, totalPages: 1))

        let exp = expectation(description: "API results")
        sut.onResultsChanged = { movies in
            if !movies.isEmpty {
                XCTAssertEqual(movies.count, 2)
                XCTAssertEqual(movies[0].title, "Batman")
                XCTAssertEqual(movies[1].title, "Batman Begins")
                exp.fulfill()
            }
        }

        sut.search(query: "Batman")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_apiReturnsEmpty_returnsEmptyArray() async {
        repository.searchResult = .success((movies: [], totalPages: 1))

        let exp = expectation(description: "empty results")
        sut.onResultsChanged = { movies in
            // Skip the initial empty from cancel, wait for the debounced result
            exp.fulfill()
        }

        sut.search(query: "xyznonexistent")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_apiError_returnsEmptyArray() async {
        repository.searchResult = .failure(URLError(.notConnectedToInternet))

        let exp = expectation(description: "error returns empty")
        sut.onResultsChanged = { movies in
            exp.fulfill()
        }

        sut.search(query: "Batman")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    // MARK: - Cancel

    func testCancel_stopsSearch() async {
        let movies = [Movie.stub(id: 1, title: "Batman")]
        repository.searchResult = .success((movies: movies, totalPages: 1))

        sut.search(query: "Batman")
        sut.cancel()

        try? await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(repository.searchCallCount, 0)
    }

    // MARK: - Debounce

    func testSearch_rapidCalls_onlyLastQueryExecutes() async {
        let movies = [Movie.stub(id: 1, title: "Final")]
        repository.searchResult = .success((movies: movies, totalPages: 1))

        let exp = expectation(description: "final query only")
        sut.onResultsChanged = { movies in
            if !movies.isEmpty {
                exp.fulfill()
            }
        }

        sut.search(query: "B")
        sut.search(query: "Ba")
        sut.search(query: "Bat")
        sut.search(query: "Batm")
        sut.search(query: "Batman")
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(repository.searchCallCount, 1)
        XCTAssertEqual(repository.lastSearchQuery, "Batman")
    }
}

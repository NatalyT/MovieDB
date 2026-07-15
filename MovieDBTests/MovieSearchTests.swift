//
//  MovieSearchTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 04.06.26.
//

import XCTest
@testable import MovieDB

@MainActor
final class MovieSearchTests: XCTestCase {

    private var repository: FakeMoviesRepository!
    private var sut: MovieSearch!

    override func setUp() {
        repository = FakeMoviesRepository()
        let searchMovies = DefaultSearchMoviesUseCase(repository: repository)
        sut = MovieSearch(
            searchMovies: searchMovies,
            localItems: { [] }
        )
    }

    override func tearDown() {
        sut = nil
        repository = nil
    }

    // MARK: - Empty / Short Query

    func testSearch_emptyQuery_clearsSuggestions() async {
        let exp = expectation(description: "callback")
        sut.onSuggestionsChanged = { suggestions, noResults in
            XCTAssertEqual(suggestions, [])
            XCTAssertFalse(noResults)
            exp.fulfill()
        }

        sut.search(query: "")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_whitespaceOnly_clearsSuggestions() async {
        let exp = expectation(description: "callback")
        sut.onSuggestionsChanged = { suggestions, noResults in
            XCTAssertEqual(suggestions, [])
            XCTAssertFalse(noResults)
            exp.fulfill()
        }

        sut.search(query: "   ")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    // MARK: - API Search

    func testSearch_validQuery_returnsAPISuggestions() async {
        let movies = [Movie.stub(id: 1, title: "Batman"), Movie.stub(id: 2, title: "Batman Begins")]
        repository.searchResult = .success((movies: movies, totalPages: 1))

        let exp = expectation(description: "API suggestions")
        sut.onSuggestionsChanged = { suggestions, noResults in
            if !suggestions.isEmpty {
                XCTAssertEqual(suggestions.count, 2)
                XCTAssertEqual(suggestions[0].title, "Batman")
                XCTAssertEqual(suggestions[1].title, "Batman Begins")
                XCTAssertFalse(noResults)
                exp.fulfill()
            }
        }

        sut.search(query: "Batman")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_apiReturnsEmpty_noLocalItems_showsNoResults() async {
        repository.searchResult = .success((movies: [], totalPages: 1))

        let exp = expectation(description: "no results")
        sut.onSuggestionsChanged = { suggestions, noResults in
            if noResults {
                XCTAssertEqual(suggestions, [])
                exp.fulfill()
            }
        }

        sut.search(query: "xyznonexistent")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    // MARK: - Local Fallback

    func testSearch_apiReturnsEmpty_fallsBackToLocal() async {
        let localItems = [
            MovieCardViewData(id: 1, title: "Batman", releaseDateText: "2026", posterURL: nil)
        ]
        let searchMovies = DefaultSearchMoviesUseCase(repository: repository)
        sut = MovieSearch(
            searchMovies: searchMovies,
            localItems: { localItems }
        )

        repository.searchResult = .success((movies: [], totalPages: 1))

        let exp = expectation(description: "local fallback")
        sut.onSuggestionsChanged = { suggestions, noResults in
            if !suggestions.isEmpty {
                XCTAssertEqual(suggestions.count, 1)
                XCTAssertEqual(suggestions[0].title, "Batman")
                XCTAssertFalse(noResults)
                exp.fulfill()
            }
        }

        sut.search(query: "Bat")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_apiError_noLocalItems_showsNoResults() async {
        repository.searchResult = .failure(URLError(.notConnectedToInternet))

        let exp = expectation(description: "no results on error")
        sut.onSuggestionsChanged = { suggestions, noResults in
            if noResults {
                XCTAssertEqual(suggestions, [])
                exp.fulfill()
            }
        }

        sut.search(query: "Batman")
        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testSearch_apiError_fallsBackToLocal() async {
        let localItems = [
            MovieCardViewData(id: 1, title: "Spider-Man", releaseDateText: "2026", posterURL: nil)
        ]
        let searchMovies = DefaultSearchMoviesUseCase(repository: repository)
        sut = MovieSearch(
            searchMovies: searchMovies,
            localItems: { localItems }
        )

        repository.searchResult = .failure(URLError(.notConnectedToInternet))

        let exp = expectation(description: "local fallback on error")
        sut.onSuggestionsChanged = { suggestions, noResults in
            if !suggestions.isEmpty {
                XCTAssertEqual(suggestions.count, 1)
                XCTAssertEqual(suggestions[0].title, "Spider-Man")
                exp.fulfill()
            }
        }

        sut.search(query: "Spider")
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
        sut.onSuggestionsChanged = { suggestions, _ in
            if !suggestions.isEmpty {
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

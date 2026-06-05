//
//  FakeMoviesRepository.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 04.06.26.
//

import Foundation
@testable import MovieDB

final class FakeMoviesRepository: MoviesRepository {

    // MARK: - Stubs

    var popularResult: Result<(movies: [Movie], totalPages: Int), Error> = .success(([], 1))
    var movieDetailResult: Result<Movie, Error> = .success(.stub())
    var searchResult: Result<(movies: [Movie], totalPages: Int), Error> = .success(([], 1))

    // MARK: - Call Tracking

    private(set) var popularCallCount = 0
    private(set) var lastPopularPage: Int?
    private(set) var searchCallCount = 0
    private(set) var lastSearchQuery: String?

    // MARK: - MoviesRepository

    func popular(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        popularCallCount += 1
        lastPopularPage = page
        return try popularResult.get()
    }

    func movieDetail(id: Int) async throws -> Movie {
        return try movieDetailResult.get()
    }

    func search(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        searchCallCount += 1
        lastSearchQuery = query
        return try searchResult.get()
    }
}

// MARK: - Movie Test Helpers

extension Movie {
    static func stub(
        id: Int = 1,
        title: String = "Test Movie",
        overview: String = "A test movie overview.",
        posterPath: String? = "/test.jpg",
        backdropPath: String? = "/backdrop.jpg",
        releaseDate: Date? = DateFormatter.tmdbDate.date(from: "2026-06-01"),
        voteAverage: Double = 7.5,
        genres: [Genre] = [Genre(id: 28, name: "Action")],
        runtime: Int? = 120,
        tagline: String? = "A test tagline",
        trailerYouTubeKey: String? = "abc123",
        cast: [CastMember] = [],
        crew: [CrewMember] = []
    ) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            genres: genres,
            runtime: runtime,
            tagline: tagline,
            trailerYouTubeKey: trailerYouTubeKey,
            cast: cast,
            crew: crew
        )
    }
}

//
//  MovieMapperTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import XCTest
@testable import MovieDB

final class MovieMapperTests: XCTestCase {

    // MARK: - TMDbMovieDTO Mapping

    func testMap_movieDTO_mapsAllFields() {
        let dto = TMDbMovieDTO(
            id: 1,
            title: "Batman",
            overview: "A dark hero.",
            posterPath: "/batman.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2026-06-01",
            voteAverage: 8.5,
            voteCount: 1000,
            genreIDs: [28, 12]
        )

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Batman")
        XCTAssertEqual(movie.overview, "A dark hero.")
        XCTAssertEqual(movie.posterPath, "/batman.jpg")
        XCTAssertEqual(movie.backdropPath, "/backdrop.jpg")
        XCTAssertNotNil(movie.releaseDate)
        XCTAssertEqual(movie.voteAverage, 8.5)
        XCTAssertTrue(movie.genres.isEmpty)
        XCTAssertNil(movie.runtime)
        XCTAssertNil(movie.tagline)
        XCTAssertNil(movie.trailerYouTubeKey)
        XCTAssertTrue(movie.cast.isEmpty)
        XCTAssertTrue(movie.crew.isEmpty)
    }

    func testMap_movieDTO_nilReleaseDate() {
        let dto = TMDbMovieDTO(
            id: 1, title: "Test", overview: "", posterPath: nil,
            backdropPath: nil, releaseDate: nil, voteAverage: 0,
            voteCount: 0, genreIDs: []
        )

        let movie = MovieMapper.map(dto)

        XCTAssertNil(movie.releaseDate)
    }

    // MARK: - TMDbMovieDetailDTO Mapping

    func testMap_detailDTO_mapsGenres() {
        let dto = makeDetailDTO(genres: [
            GenreDTO(id: 28, name: "Action"),
            GenreDTO(id: 12, name: "Adventure")
        ])

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.genres.count, 2)
        XCTAssertEqual(movie.genres[0].name, "Action")
        XCTAssertEqual(movie.genres[1].name, "Adventure")
    }

    func testMap_detailDTO_mapsRuntime() {
        let dto = makeDetailDTO(runtime: 148)

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.runtime, 148)
    }

    func testMap_detailDTO_mapsTagline() {
        let dto = makeDetailDTO(tagline: "Why so serious?")

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.tagline, "Why so serious?")
    }

    func testMap_detailDTO_extractsYouTubeTrailerKey() {
        let videos = TMDbVideosDTO(results: [
            TMDbVideoDTO(key: "abc123", site: "YouTube", type: "Trailer"),
            TMDbVideoDTO(key: "xyz789", site: "YouTube", type: "Featurette")
        ])
        let dto = makeDetailDTO(videos: videos)

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.trailerYouTubeKey, "abc123")
    }

    func testMap_detailDTO_noTrailer_returnsNil() {
        let videos = TMDbVideosDTO(results: [
            TMDbVideoDTO(key: "xyz789", site: "YouTube", type: "Featurette")
        ])
        let dto = makeDetailDTO(videos: videos)

        let movie = MovieMapper.map(dto)

        XCTAssertNil(movie.trailerYouTubeKey)
    }

    func testMap_detailDTO_noVideos_returnsNil() {
        let dto = makeDetailDTO(videos: nil)

        let movie = MovieMapper.map(dto)

        XCTAssertNil(movie.trailerYouTubeKey)
    }

    func testMap_detailDTO_mapsCast() {
        let credits = TMDbCreditsDTO(
            cast: [TMDbCastDTO(id: 1, name: "Jon", character: "Frank", profilePath: "/jon.jpg")],
            crew: []
        )
        let dto = makeDetailDTO(credits: credits)

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.cast.count, 1)
        XCTAssertEqual(movie.cast[0].name, "Jon")
        XCTAssertEqual(movie.cast[0].character, "Frank")
    }

    func testMap_detailDTO_mapsCrew() {
        let credits = TMDbCreditsDTO(
            cast: [],
            crew: [TMDbCrewDTO(id: 1, name: "Tom", job: "Director", profilePath: nil)]
        )
        let dto = makeDetailDTO(credits: credits)

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.crew.count, 1)
        XCTAssertEqual(movie.crew[0].name, "Tom")
        XCTAssertEqual(movie.crew[0].job, "Director")
    }

    func testMap_detailDTO_regionalReleaseDate() {
        let releaseDates = TMDbReleaseDatesDTO(results: [
            TMDbCountryReleaseDTO(countryCode: "DE", releaseDates: [
                TMDbReleaseDateEntryDTO(releaseDate: "2026-05-20T00:00:00.000Z", type: 3)
            ])
        ])
        let dto = makeDetailDTO(releaseDate: "2026-06-01", releaseDates: releaseDates)

        let movie = MovieMapper.map(dto, region: "DE")

        // Should use regional date (May 20), not primary (June 1)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.month, from: movie.releaseDate!), 5)
        XCTAssertEqual(calendar.component(.day, from: movie.releaseDate!), 20)
    }

    func testMap_detailDTO_fallsBackToPrimaryDate() {
        let dto = makeDetailDTO(releaseDate: "2026-06-01", releaseDates: nil)

        let movie = MovieMapper.map(dto, region: "DE")

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.month, from: movie.releaseDate!), 6)
    }

    // MARK: - TMDbPersonCastCreditDTO Mapping

    func testMap_personCastCredit_mapsCorrectly() {
        let dto = TMDbPersonCastCreditDTO(
            id: 42, title: "Fury", posterPath: "/fury.jpg",
            releaseDate: "2014-10-15", voteAverage: 7.5,
            voteCount: 12000, popularity: 14.97
        )

        let movie = MovieMapper.map(dto)

        XCTAssertEqual(movie.id, 42)
        XCTAssertEqual(movie.title, "Fury")
        XCTAssertEqual(movie.posterPath, "/fury.jpg")
        XCTAssertNotNil(movie.releaseDate)
        XCTAssertTrue(movie.overview.isEmpty)
        XCTAssertTrue(movie.genres.isEmpty)
    }

    // MARK: - Helpers

    private func makeDetailDTO(
        releaseDate: String? = "2026-06-01",
        genres: [GenreDTO] = [],
        runtime: Int? = nil,
        tagline: String? = nil,
        releaseDates: TMDbReleaseDatesDTO? = nil,
        videos: TMDbVideosDTO? = nil,
        credits: TMDbCreditsDTO? = nil
    ) -> TMDbMovieDetailDTO {
        TMDbMovieDetailDTO(
            id: 1,
            title: "Test Movie",
            overview: "Overview",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: releaseDate,
            voteAverage: 7.0,
            voteCount: 100,
            genres: genres,
            runtime: runtime,
            tagline: tagline,
            releaseDates: releaseDates,
            videos: videos,
            credits: credits
        )
    }
}

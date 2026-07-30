//
//  TMDbMovieDetailDTO.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

struct TMDbMovieDetailDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let genres: [GenreDTO]
    let runtime: Int?
    let tagline: String?
    let releaseDates: TMDbReleaseDatesDTO?
    let videos: TMDbVideosDTO?
    let credits: TMDbCreditsDTO?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, runtime, tagline, videos, credits
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case releaseDates = "release_dates"
    }

}

// MARK: - Release Dates DTOs

struct TMDbReleaseDatesDTO: Decodable {
    let results: [TMDbCountryReleaseDTO]
}

struct TMDbCountryReleaseDTO: Decodable {
    let countryCode: String
    let releaseDates: [TMDbReleaseDateEntryDTO]

    enum CodingKeys: String, CodingKey {
        case countryCode = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct TMDbReleaseDateEntryDTO: Decodable {
    let releaseDate: String
    let type: Int

    enum CodingKeys: String, CodingKey {
        case releaseDate = "release_date"
        case type
    }
}

// MARK: - Video DTOs

struct TMDbVideosDTO: Decodable {
    let results: [TMDbVideoDTO]
}

struct TMDbVideoDTO: Decodable {
    let key: String
    let site: String
    let type: String
}

// MARK: - Credits DTOs

struct TMDbCreditsDTO: Decodable {
    let cast: [TMDbCastDTO]
    let crew: [TMDbCrewDTO]
}

struct TMDbCastDTO: Decodable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

struct TMDbCrewDTO: Decodable {
    let id: Int
    let name: String
    let job: String
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, job
        case profilePath = "profile_path"
    }
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String
}

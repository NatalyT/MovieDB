//
//  TMDbMovieDetailDTO.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

private enum Constants {
    static let theatricalReleaseType = 3
    static let youTubeSite = "YouTube"
    static let trailerType = "Trailer"
}

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

    func toDomainModel(region: String = "US") -> Movie {
        let date = regionalReleaseDate(for: region) ?? primaryReleaseDate()

        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: date,
            voteAverage: voteAverage,
            genres: genres.map { Genre(id: $0.id, name: $0.name) },
            runtime: runtime,
            tagline: tagline,
            trailerYouTubeKey: youTubeTrailerKey(),
            cast: credits?.cast.map { CastMember(id: $0.id, name: $0.name, character: $0.character, profilePath: $0.profilePath) } ?? []
        )
    }

    // MARK: - Private

    private func primaryReleaseDate() -> Date? {
        releaseDate.flatMap { DateFormatter.tmdbDate.date(from: $0) }
    }

    private func youTubeTrailerKey() -> String? {
        videos?.results.first {
            $0.site == Constants.youTubeSite && $0.type == Constants.trailerType
        }?.key
    }

    private func regionalReleaseDate(for region: String) -> Date? {
        guard let countryRelease = releaseDates?.results.first(where: { $0.countryCode == region }) else {
            return nil
        }

        let theatrical = countryRelease.releaseDates
            .first { $0.type == Constants.theatricalReleaseType }

        guard let dateString = theatrical?.releaseDate else { return nil }

        return DateFormatter.tmdbDateTime.date(from: dateString)
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

struct GenreDTO: Decodable {
    let id: Int
    let name: String
}

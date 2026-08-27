//
//  MovieMapper.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Domain
import Foundation

private enum Constants {
    static let theatricalReleaseType = 3
    static let youTubeSite = "YouTube"
    static let trailerType = "Trailer"
}

enum MovieMapper {

    static func map(_ dto: TMDbMovieDTO) -> Movie {
        let date = dto.releaseDate.flatMap { DateFormatter.tmdbDate.date(from: $0) }

        return Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            releaseDate: date,
            voteAverage: dto.voteAverage,
            genres: [],
            runtime: nil,
            tagline: nil,
            trailerYouTubeKey: nil,
            cast: [],
            crew: []
        )
    }

    static func map(_ dto: TMDbMovieDetailDTO, region: String = "US") -> Movie {
        let date = regionalReleaseDate(from: dto, region: region)
            ?? dto.releaseDate.flatMap { DateFormatter.tmdbDate.date(from: $0) }

        return Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            releaseDate: date,
            voteAverage: dto.voteAverage,
            genres: dto.genres.map { Genre(id: $0.id, name: $0.name) },
            runtime: dto.runtime,
            tagline: dto.tagline,
            trailerYouTubeKey: youTubeTrailerKey(from: dto),
            cast: dto.credits?.cast.map { CastMember(id: $0.id, name: $0.name, character: $0.character, profilePath: $0.profilePath) } ?? [],
            crew: dto.credits?.crew.map { CrewMember(id: $0.id, name: $0.name, job: $0.job, profilePath: $0.profilePath) } ?? []
        )
    }

    static func map(_ dto: TMDbPersonCastCreditDTO) -> Movie {
        let date = dto.releaseDate.flatMap { DateFormatter.tmdbDate.date(from: $0) }

        return Movie(
            id: dto.id,
            title: dto.title,
            overview: "",
            posterPath: dto.posterPath,
            backdropPath: nil,
            releaseDate: date,
            voteAverage: dto.voteAverage,
            genres: [],
            runtime: nil,
            tagline: nil,
            trailerYouTubeKey: nil,
            cast: [],
            crew: []
        )
    }

    // MARK: - Private

    private static func youTubeTrailerKey(from dto: TMDbMovieDetailDTO) -> String? {
        dto.videos?.results.first {
            $0.site == Constants.youTubeSite && $0.type == Constants.trailerType
        }?.key
    }

    private static func regionalReleaseDate(from dto: TMDbMovieDetailDTO, region: String) -> Date? {
        guard let countryRelease = dto.releaseDates?.results.first(where: { $0.countryCode == region }) else {
            return nil
        }

        let theatrical = countryRelease.releaseDates
            .first { $0.type == Constants.theatricalReleaseType }

        guard let dateString = theatrical?.releaseDate else { return nil }

        return DateFormatter.tmdbDateTime.date(from: dateString)
    }
}

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

    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, runtime, tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    func toDomainModel() -> Movie {
        let formatter = DateFormatter.tmdbDate
        let date = releaseDate.flatMap { formatter.date(from: $0) }

        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: date,
            voteAverage: voteAverage,
            voteCount: voteCount,
            genreIDs: genres.map(\.id),
            genres: genres.map { Genre(id: $0.id, name: $0.name) },
            runtime: runtime,
            tagline: tagline
        )
    }
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String
}

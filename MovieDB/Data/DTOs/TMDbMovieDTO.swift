//
//  TMDbMovieDTO.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

struct TMDbMovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let genreIDs: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIDs = "genre_ids"
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
            genres: [],
            runtime: nil,
            tagline: nil,
            trailerYouTubeKey: nil,
            cast: [],
            crew: []
        )
    }
}

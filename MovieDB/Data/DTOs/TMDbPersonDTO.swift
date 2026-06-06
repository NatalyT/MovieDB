//
//  TMDbPersonDTO.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import Foundation

struct TMDbPersonDTO: Decodable {
    let id: Int
    let name: String
    let biography: String
    let profilePath: String?
    let birthday: String?
    let placeOfBirth: String?
    let gender: Int
    let knownForDepartment: String?
    let movieCredits: TMDbPersonMovieCreditsDTO?

    enum CodingKeys: String, CodingKey {
        case id, name, biography, birthday, gender
        case profilePath = "profile_path"
        case placeOfBirth = "place_of_birth"
        case knownForDepartment = "known_for_department"
        case movieCredits = "movie_credits"
    }

    func toDomainModel() -> Person {
        let birthDate = birthday.flatMap { DateFormatter.tmdbDate.date(from: $0) }
        let movies = movieCredits?.cast
            .filter { $0.voteCount > 0 }
            .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
            .map { $0.toDomainModel() } ?? []

        return Person(
            id: id,
            name: name,
            biography: biography,
            profilePath: profilePath,
            birthday: birthDate,
            placeOfBirth: placeOfBirth,
            gender: Gender(rawValue: gender) ?? .unknown,
            knownForDepartment: knownForDepartment,
            knownForMovies: movies
        )
    }
}

// MARK: - Person Movie Credits

struct TMDbPersonMovieCreditsDTO: Decodable {
    let cast: [TMDbPersonCastCreditDTO]
}

struct TMDbPersonCastCreditDTO: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double?

    enum CodingKeys: String, CodingKey {
        case id, title, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    func toDomainModel() -> Movie {
        let date = releaseDate.flatMap { DateFormatter.tmdbDate.date(from: $0) }
        return Movie(
            id: id,
            title: title,
            overview: "",
            posterPath: posterPath,
            backdropPath: nil,
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

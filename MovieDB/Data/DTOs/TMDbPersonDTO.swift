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
}

//
//  PersonMapper.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

enum PersonMapper {

    static func map(_ dto: TMDbPersonDTO) -> Person {
        let birthDate = dto.birthday.flatMap { DateFormatter.tmdbDate.date(from: $0) }
        let movies = dto.movieCredits?.cast
            .filter { $0.voteCount > 0 }
            .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
            .map { MovieMapper.map($0) } ?? []

        return Person(
            id: dto.id,
            name: dto.name,
            biography: dto.biography,
            profilePath: dto.profilePath,
            birthday: birthDate,
            placeOfBirth: dto.placeOfBirth,
            gender: Gender(rawValue: dto.gender) ?? .unknown,
            knownForDepartment: dto.knownForDepartment,
            knownForMovies: movies
        )
    }
}

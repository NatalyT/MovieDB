//
//  Movie.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

struct Movie: Equatable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: Date?
    let voteAverage: Double
    let genres: [Genre]
    let runtime: Int?
    let tagline: String?
    let trailerYouTubeKey: String?
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Equatable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
}

struct CrewMember: Equatable, Identifiable {
    let id: Int
    let name: String
    let job: String
    let profilePath: String?
}

//
//  Movie.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

public struct Movie: Equatable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: Date?
    public let voteAverage: Double
    public let genres: [Genre]
    public let runtime: Int?
    public let tagline: String?
    public let trailerYouTubeKey: String?
    public let cast: [CastMember]
    public let crew: [CrewMember]

    public init(id: Int, title: String, overview: String, posterPath: String?,
                backdropPath: String?, releaseDate: Date?, voteAverage: Double,
                genres: [Genre], runtime: Int?, tagline: String?,
                trailerYouTubeKey: String?, cast: [CastMember], crew: [CrewMember]) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.genres = genres
        self.runtime = runtime
        self.tagline = tagline
        self.trailerYouTubeKey = trailerYouTubeKey
        self.cast = cast
        self.crew = crew
    }
}

public struct CastMember: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let character: String
    public let profilePath: String?

    public init(id: Int, name: String, character: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
    }
}

public struct CrewMember: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let job: String
    public let profilePath: String?

    public init(id: Int, name: String, job: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.job = job
        self.profilePath = profilePath
    }
}

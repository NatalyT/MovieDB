//
//  Person.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import Foundation

public struct Person: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let biography: String
    public let profilePath: String?
    public let birthday: Date?
    public let placeOfBirth: String?
    public let gender: Gender
    public let knownForDepartment: String?
    public let knownForMovies: [Movie]

    public init(id: Int, name: String, biography: String, profilePath: String?,
                birthday: Date?, placeOfBirth: String?, gender: Gender,
                knownForDepartment: String?, knownForMovies: [Movie]) {
        self.id = id
        self.name = name
        self.biography = biography
        self.profilePath = profilePath
        self.birthday = birthday
        self.placeOfBirth = placeOfBirth
        self.gender = gender
        self.knownForDepartment = knownForDepartment
        self.knownForMovies = knownForMovies
    }
}

public enum Gender: Int, Equatable, Sendable {
    case unknown = 0
    case female = 1
    case male = 2
    case nonBinary = 3
}

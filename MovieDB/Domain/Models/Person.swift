//
//  Person.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import Foundation

struct Person: Equatable, Identifiable {
    let id: Int
    let name: String
    let biography: String
    let profilePath: String?
    let birthday: Date?
    let placeOfBirth: String?
    let gender: Gender
    let knownForDepartment: String?
    let knownForMovies: [Movie]
}

enum Gender: Int, Equatable {
    case unknown = 0
    case female = 1
    case male = 2
    case nonBinary = 3
}

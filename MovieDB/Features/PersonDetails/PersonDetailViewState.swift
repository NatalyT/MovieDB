//
//  PersonDetailViewState.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import Foundation

enum PersonDetailViewState {
    case loading
    case loaded(PersonDetailLoadedState)
    case error(String)
}

struct PersonDetailLoadedState: Equatable {
    let name: String
    let biography: String
    let photoURL: URL?
    let knownForDepartment: String?
    let genderText: String
    let birthdayText: String?
    let placeOfBirth: String?
    let knownForMovies: [PersonKnownForMovie]
}

struct PersonKnownForMovie: Identifiable, Equatable {
    let id: Int
    let title: String
    let posterURL: URL?
}

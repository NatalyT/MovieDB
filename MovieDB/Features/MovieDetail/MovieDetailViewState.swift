//
//  MovieDetailViewState.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import Foundation

enum MovieDetailViewState {
    case loading
    case loaded(MovieDetailLoadedState)
    case error(String)
}

struct MovieDetailLoadedState: Equatable {
    let title: String
    let yearText: String
    let tagline: String?
    let overview: String
    let scorePercent: Int
    let scoreText: String
    let releaseDateText: String
    let genresText: String
    let runtimeText: String?
    let posterURL: URL?
    let backdropURL: URL?
    let trailerURL: URL?
    let cast: [CastViewData]
    let crew: [CrewViewData]
}

struct CastViewData: Identifiable, Equatable {
    let id: Int
    let name: String
    let character: String
    let photoURL: URL?
}

struct CrewViewData: Identifiable, Equatable {
    let id: Int
    let name: String
    let job: String
    let photoURL: URL?
}

//
//  MovieDetailViewState.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import Foundation

enum MovieDetailViewState {
    case loading
    case loaded(MovieDetailData)
    case error(String)
}

struct MovieDetailData: Equatable {
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
}

//
//  MovieListViewState.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

enum MovieListViewState {
    case loading
    case loaded(MovieListLoadedState)
    case empty
    case error(String)
}

struct MovieListLoadedState: Equatable {
    let items: [MovieCardViewData]
    let isLoadingMore: Bool
    let loadMoreError: String?
}

struct MovieSuggestion: Identifiable, Equatable {
    let id: Int
    let title: String
    let releaseDateText: String
}

struct MovieCardViewData: Identifiable, Equatable {
    let id: Int
    let title: String
    let releaseDateText: String
    let posterURL: URL?
}

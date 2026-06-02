//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import SwiftUI

private enum Constants {
    static let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMWI0MmFhNTZiYjhmMjg4MTZkMjE1OWU4NGZlYjRlYiIsIm5iZiI6MTc4MDA0NzUzNC43NTcsInN1YiI6IjZhMTk1ZWFlNTVmYjU1YjA4Njc0NGQyYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.T__3ER6VUDfSYETRK4Efi9zmd_T1rxiEGzkuzPUkTdE"
}

@main
struct MovieDBApp: App {

    var body: some Scene {
        WindowGroup {
            MovieListView(viewModel: makeMovieListViewModel())
        }
    }

    private func makeMovieListViewModel() -> MovieListViewModel {
        let http = URLSessionHTTPClient()
        let api = TMDbAPIClient(http: http, bearerToken: Constants.bearerToken)
        return MovieListViewModel(repository: api)
    }
}

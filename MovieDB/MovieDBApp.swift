//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import SwiftUI

@main
struct MovieDBApp: App {

    var body: some Scene {
        WindowGroup {
            MovieListView(viewModel: makeMovieListViewModel())
        }
    }

    private func makeMovieListViewModel() -> MovieListViewModel {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDBBearerToken") as? String,
              !token.isEmpty else {
            fatalError("Missing TMDB Bearer Token. See README for setup instructions.")
        }

        let http = URLSessionHTTPClient()
        let api = TMDbAPIClient(http: http, bearerToken: token)
        return MovieListViewModel(repository: api)
    }
}

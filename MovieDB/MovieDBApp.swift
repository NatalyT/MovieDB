//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import SwiftUI

@main
struct MovieDBApp: App {

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        UINavigationBar.appearance().tintColor = .label
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            MovieListView(viewModel: makeMovieListViewModel())
                .tint(.primary)
        }
    }

    private func makeMovieListViewModel() -> MovieListViewModel {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDBBearerToken") as? String,
              !token.isEmpty else {
            fatalError("Missing TMDB Bearer Token. See README for setup instructions.")
        }

        let http = URLSessionHTTPClient()
        let api = TMDbAPIClient(http: http, bearerToken: token)
        let getPopularMovies = DefaultGetPopularMoviesUseCase(repository: api)
        return MovieListViewModel(getPopularMovies: getPopularMovies, repository: api)
    }
}

//
//  ViewModelFactory.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Combine
import Domain
import Foundation

@MainActor
final class ViewModelFactory: ObservableObject {

    private let repository: MoviesRepository
    private let getPopularMovies: GetPopularMoviesUseCase
    private let searchMovies: SearchMoviesUseCase
    private let getMovieDetail: GetMovieDetailUseCase
    private let getPersonDetail: GetPersonDetailUseCase

    static func create() -> ViewModelFactory {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDBBearerToken") as? String,
              !token.isEmpty else {
            fatalError("Missing TMDB Bearer Token. See README for setup instructions.")
        }

        let http = URLSessionHTTPClient()
        let apiClient = TMDbAPIClient(http: http, bearerToken: token)
        let repository = DefaultMoviesRepository(apiClient: apiClient)
        return ViewModelFactory(repository: repository)
    }

    init(repository: MoviesRepository) {
        self.repository = repository
        self.getPopularMovies = DefaultGetPopularMoviesUseCase(repository: repository)
        self.searchMovies = DefaultSearchMoviesUseCase(repository: repository)
        self.getMovieDetail = DefaultGetMovieDetailUseCase(repository: repository)
        self.getPersonDetail = DefaultGetPersonDetailUseCase(repository: repository)
    }

    func makeMovieListViewModel() -> MovieListViewModel {
        let search = MovieSearch(searchMovies: searchMovies)
        return MovieListViewModel(getPopularMovies: getPopularMovies, search: search)
    }

    func makeMovieDetailViewModel(for movieID: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieID: movieID, getMovieDetail: getMovieDetail)
    }

    func makePersonDetailViewModel(for personID: Int) -> PersonDetailViewModel {
        PersonDetailViewModel(personID: personID, getPersonDetail: getPersonDetail)
    }
}

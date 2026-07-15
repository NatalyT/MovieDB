//
//  GetPopularMoviesUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

protocol GetPopularMoviesUseCase {
    func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int)
}

final class DefaultGetPopularMoviesUseCase: GetPopularMoviesUseCase {

    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        try await repository.popular(page: page)
    }
}

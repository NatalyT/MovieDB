//
//  GetMovieDetailUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

protocol GetMovieDetailUseCase {
    func execute(id: Int) async throws -> Movie
}

final class DefaultGetMovieDetailUseCase: GetMovieDetailUseCase {

    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Movie {
        try await repository.movieDetail(id: id)
    }
}

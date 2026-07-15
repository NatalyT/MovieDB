//
//  SearchMoviesUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

protocol SearchMoviesUseCase {
    func execute(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int)
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        try await repository.search(query: query, page: page)
    }
}

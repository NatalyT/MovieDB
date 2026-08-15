//
//  GetPopularMoviesUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

public protocol GetPopularMoviesUseCase: Sendable {
    func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int)
}

public final class DefaultGetPopularMoviesUseCase: GetPopularMoviesUseCase {

    private let repository: MoviesRepository

    public init(repository: MoviesRepository) {
        self.repository = repository
    }

    public func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        try await repository.popular(page: page)
    }
}

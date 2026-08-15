//
//  GetMovieDetailUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

public protocol GetMovieDetailUseCase: Sendable {
    func execute(id: Int) async throws -> Movie
}

public final class DefaultGetMovieDetailUseCase: GetMovieDetailUseCase {

    private let repository: MoviesRepository

    public init(repository: MoviesRepository) {
        self.repository = repository
    }

    public func execute(id: Int) async throws -> Movie {
        try await repository.movieDetail(id: id)
    }
}

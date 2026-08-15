//
//  SearchMoviesUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

public protocol SearchMoviesUseCase: Sendable {
    func execute(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int)
}

public final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let repository: MoviesRepository

    public init(repository: MoviesRepository) {
        self.repository = repository
    }

    public func execute(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        try await repository.search(query: query, page: page)
    }
}

//
//  DefaultMoviesRepository.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Domain
import Foundation

final class DefaultMoviesRepository: MoviesRepository {

    private let apiClient: TMDbAPIClient

    init(apiClient: TMDbAPIClient) {
        self.apiClient = apiClient
    }

    func popular(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        try await apiClient.popular(page: page)
    }

    func movieDetail(id: Int) async throws -> Movie {
        try await apiClient.movieDetail(id: id)
    }

    func search(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        try await apiClient.search(query: query, page: page)
    }

    func personDetail(id: Int) async throws -> Person {
        try await apiClient.personDetail(id: id)
    }
}

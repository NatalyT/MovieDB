//
//  MoviesRepository.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

public protocol MoviesRepository: Sendable {
    func popular(page: Int) async throws -> (movies: [Movie], totalPages: Int)
    func movieDetail(id: Int) async throws -> Movie
    func search(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int)
    func personDetail(id: Int) async throws -> Person
}

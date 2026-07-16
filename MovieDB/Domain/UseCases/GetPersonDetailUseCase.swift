//
//  GetPersonDetailUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

protocol GetPersonDetailUseCase {
    func execute(id: Int) async throws -> Person
}

final class DefaultGetPersonDetailUseCase: GetPersonDetailUseCase {

    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Person {
        try await repository.personDetail(id: id)
    }
}

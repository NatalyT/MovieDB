//
//  GetPersonDetailUseCase.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import Foundation

public protocol GetPersonDetailUseCase: Sendable {
    func execute(id: Int) async throws -> Person
}

public final class DefaultGetPersonDetailUseCase: GetPersonDetailUseCase {

    private let repository: MoviesRepository

    public init(repository: MoviesRepository) {
        self.repository = repository
    }

    public func execute(id: Int) async throws -> Person {
        try await repository.personDetail(id: id)
    }
}

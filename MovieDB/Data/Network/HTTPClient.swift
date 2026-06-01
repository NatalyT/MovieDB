//
//  HTTPClient.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

enum HTTPClientError: Error {
    case invalidResponse
    case httpStatus(Int)
}

protocol HTTPClient {
    func execute(_ request: URLRequest) async throws -> Data
}

final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func execute(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw HTTPClientError.httpStatus(http.statusCode)
        }

        return data
    }
}

//
//  HTTPClient.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

public enum HTTPClientError: Error {
    case invalidResponse
    case httpStatus(Int)
}

public protocol HTTPClient: Sendable {
    func execute(_ request: URLRequest) async throws -> Data
}

public final class URLSessionHTTPClient: HTTPClient, @unchecked Sendable {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func execute(_ request: URLRequest) async throws -> Data {
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

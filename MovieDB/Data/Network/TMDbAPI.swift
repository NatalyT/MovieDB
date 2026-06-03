//
//  TMDbAPI.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

private enum Constants {
    static let baseURL = "https://api.themoviedb.org/3"
}

enum TMDbAPIError: Error {
    case invalidURL
    case decodingFailed
}

final class TMDbAPIClient: MoviesRepository {

    private let http: HTTPClient
    private let bearerToken: String
    private let decoder: JSONDecoder
    private let language: String
    private let region: String

    init(http: HTTPClient, bearerToken: String, locale: Locale = .current, decoder: JSONDecoder = JSONDecoder()) {
        self.http = http
        self.bearerToken = bearerToken
        self.decoder = decoder

        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let regionCode = locale.region?.identifier ?? "US"
        self.language = "\(languageCode)-\(regionCode)"
        self.region = regionCode
    }

    // MARK: - MoviesRepository

    func popular(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        let url = try makeURL(path: "/movie/popular", queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])

        let dto: TMDbPageDTO<TMDbMovieDTO> = try await fetchAndDecode(url: url)
        let movies = dto.results.map { $0.toDomainModel() }

        return (movies: movies, totalPages: dto.totalPages)
    }

    func movieDetail(id: Int) async throws -> Movie {
        let url = try makeURL(path: "/movie/\(id)", queryItems: [
            URLQueryItem(name: "append_to_response", value: "release_dates")
        ])
        let dto: TMDbMovieDetailDTO = try await fetchAndDecode(url: url)

        return dto.toDomainModel(region: region)
    }

    func search(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        let url = try makeURL(path: "/search/movie", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page))
        ])

        let dto: TMDbPageDTO<TMDbMovieDTO> = try await fetchAndDecode(url: url)
        let movies = dto.results.map { $0.toDomainModel() }

        return (movies: movies, totalPages: dto.totalPages)
    }

    // MARK: - Private

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        var components = URLComponents(string: Constants.baseURL + path)

        var allItems = [
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "region", value: region)
        ]
        allItems.append(contentsOf: queryItems)
        components?.queryItems = allItems

        guard let url = components?.url else { throw TMDbAPIError.invalidURL }
        return url
    }

    private func fetchAndDecode<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let data = try await http.execute(request)

        #if DEBUG
        if let json = String(data: data, encoding: .utf8) {
            print("[\(request.url?.path ?? "")] \(json)")
        }
        #endif

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw TMDbAPIError.decodingFailed
        }
    }
}

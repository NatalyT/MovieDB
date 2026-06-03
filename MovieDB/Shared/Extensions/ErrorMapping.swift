//
//  ErrorMapping.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 03.06.26.
//

import Foundation

enum ErrorMapping {

    static func mapToAlert(_ error: Error) -> String {
        switch error {
        case let apiError as TMDbAPIError:
            switch apiError {
            case .invalidURL:
                return AppStrings.Error.invalidURL
            case .decodingFailed:
                return AppStrings.Error.decodingFailed
            }

        case let httpError as HTTPClientError:
            switch httpError {
            case .invalidResponse:
                return AppStrings.Error.invalidResponse
            case .httpStatus(let code):
                return AppStrings.Error.httpStatus(code)
            }

        case is URLError:
            return AppStrings.Error.network

        default:
            return AppStrings.Error.unknown
        }
    }
}

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
                return String(localized: "error.invalidURL", defaultValue: "Invalid request.")
            case .decodingFailed:
                return String(localized: "error.decodingFailed", defaultValue: "Could not read server data.")
            }

        case let httpError as HTTPClientError:
            switch httpError {
            case .invalidResponse:
                return String(localized: "error.invalidResponse", defaultValue: "Invalid server response.")
            case .httpStatus(let code):
                let format = String(localized: "error.httpStatus", defaultValue: "Request failed (HTTP %d).")
                return String(format: format, code)
            }

        case is URLError:
            return String(localized: "error.network", defaultValue: "Network error. Please try again.")

        default:
            return String(localized: "error.unknown", defaultValue: "Something went wrong.")
        }
    }
}

//
//  AppStrings.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

enum AppStrings {
    static let appTitle = "MovieDB"
    static let nowPlaying = "Now Playing"
    static let search = "Search"
    static let searchPlaceholder = "Search movies..."
    static let noResults = "No movies found."
    static let genres = "Genres"
    static let overview = "Overview"
    static let rating = "Rating"
    static let releaseDate = "Release Date"
    static let runtime = "Runtime"
    static let minutes = "min"

    enum Error {
        static let invalidURL = "Invalid request."
        static let decodingFailed = "Could not read server data."
        static let invalidResponse = "Invalid server response."
        static func httpStatus(_ code: Int) -> String { "Request failed (HTTP \(code))." }
        static let network = "Network error. Please try again."
        static let unknown = "Something went wrong."
    }
}

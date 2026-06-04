//
//  ImageURL.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import Foundation

private enum Constants {
    static let imageBaseURL = "https://image.tmdb.org/t/p/"
}

enum ImageSize: String {
    case w185
    case w500
}

enum ImageURL {
    static func url(path: String, size: ImageSize = .w500) -> URL? {
        URL(string: Constants.imageBaseURL + size.rawValue + path)
    }
}

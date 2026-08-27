//
//  TMDbDateFormatters.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import Foundation

extension DateFormatter {

    public static let tmdbDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    public static let tmdbDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

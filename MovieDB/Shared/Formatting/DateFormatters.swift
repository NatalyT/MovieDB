//
//  DateFormatters.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import Foundation

extension DateFormatter {

    static let tmdbDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

//
//  DateFormatters.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import Foundation

extension DateFormatter {

    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = .current
        return formatter
    }()

    static func displayString(from date: Date?) -> String {
        date.map { displayDate.string(from: $0) } ?? ""
    }
}

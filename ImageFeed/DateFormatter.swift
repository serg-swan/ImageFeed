//
//  DateFormatter.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 03.07.2025.
//

import Foundation

extension DateFormatter {
    static let russianMediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

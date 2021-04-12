//
//  DateExtension.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 29.03.21.
//

import Foundation

extension Date {
    var dateInISO8601: String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullTime,
                                       .withTimeZone,
                                       .withFullDate,
                                       .withDashSeparatorInDate,
                                       .withFractionalSeconds]
        
        return dateFormatter.string(from: self)
    }
}

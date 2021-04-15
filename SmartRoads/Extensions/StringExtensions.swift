//
//  StringExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 13.04.21.
//

import Foundation

extension String {
    var wordList: [String] {
        return components(separatedBy: ", ").filter { !$0.isEmpty }
    }
}

//
//  UserDefaultsDData.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 12.04.21.
//

import Foundation

class UserDefaultsData {
    static var frames: Int {
        get {
            UserDefaults.standard.integer(forKey: "fps")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "fps")
            UserDefaults.standard.synchronize()
        }
    }
}

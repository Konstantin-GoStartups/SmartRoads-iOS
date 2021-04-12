//
//  IntExtension.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 29.03.21.
//

import Foundation

extension Int {
    func sizeToDisplay() -> String {
        let kb = 1000
        let mb = kb * 1000
        let gb = mb * 1000
        let tb = gb * 1000
        let qotient: Float
        let unit: String
        if self < kb {
            qotient = Float(self)
            unit = "bytes"
        } else if self < mb {
            qotient = Float(self/kb)
            unit = "kb"
        } else if self < gb {
            qotient = Float(self/mb)
            unit = "mb"
        } else if self < tb {
            qotient = Float(self/gb)
            unit = "gb"
        } else {
            qotient = Float(self/tb)
            unit = "tb"
        }
        
        return "\(qotient) \(unit)"
    }
}

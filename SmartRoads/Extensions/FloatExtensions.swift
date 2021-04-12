//
//  FloatExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 5.04.21.
//

import Foundation

typealias Float3 = SIMD3<Float>

extension Float {
    static let degreesToRadian = Float.pi / 180
    
    func round(to places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
    
}



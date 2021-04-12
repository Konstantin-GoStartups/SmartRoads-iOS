//
//  SensorData.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 29.03.21.
//

import Foundation
import RealmSwift

class SensorData: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var frame: Int = 0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var xAcceleration: Double = 0.0
    @objc dynamic var yAcceleration: Double = 0.0
    @objc dynamic var zAcceleration: Double = 0.0
    @objc dynamic var matrix: String = ""
    @objc dynamic var intrinsics: String = ""
    @objc dynamic var projectionMatrix: String = ""
    @objc dynamic var eulerAngle: String = ""
    @objc dynamic var minimumDistance: Float = 0.0
    @objc dynamic var maximumDistance: Float = 0.0
    @objc dynamic var defaultPixelData: String = ""
    @objc dynamic var normalisedPixelData: String = ""
    @objc dynamic var clampedPixelData: String = ""
    @objc dynamic var finalPixelData: String = ""
    
    override init() {
        
    }
    
    convenience init(frame: Int, latitude: Double, longitude: Double, xAcceleration: Double, yAcceleration: Double, zAcceleration: Double, matrix: String, intrinsics: String, projectionMatrix: String, eulerAngle: String, minimumDistance: Float, maximumDistance: Float, defaultPixelData: String, normalisedPixelData: String, clampedPixelData: String, finalPixelData: String) {
        self.init()
        self.frame = frame
        self.latitude = latitude
        self.longitude = longitude
        self.xAcceleration = xAcceleration
        self.yAcceleration = yAcceleration
        self.zAcceleration = zAcceleration
        self.matrix = matrix
        self.intrinsics = intrinsics
        self.projectionMatrix = projectionMatrix
        self.eulerAngle = eulerAngle
        self.minimumDistance = minimumDistance
        self.maximumDistance = maximumDistance
        self.defaultPixelData = defaultPixelData.debugDescription
        self.normalisedPixelData = normalisedPixelData.debugDescription
        self.clampedPixelData = clampedPixelData
        self.finalPixelData = finalPixelData
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

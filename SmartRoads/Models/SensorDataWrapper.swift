//
//  SensorDatawrapper.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 29.03.21.
//

import Foundation


import Foundation
import RealmSwift

class SensorDataWrapper: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var startDate: String = ""
    dynamic var sensorDataList: List<SensorData> = List<SensorData>()
    @objc dynamic var endDate: String?
    @objc dynamic var depthVideoURL: String = ""
    @objc dynamic var uuid: String = ""
    @objc dynamic var rgbVideoURL: String = ""
    @objc dynamic var confidenceVideoURL: String = ""
    @objc dynamic var jsonFileURL: String?
    @objc dynamic var street: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var country: String = ""
    
    override init() {
        
    }
    
    convenience init(startDate: String, sensorDataList: List<SensorData>, endDate: String? = "") {
        self.init()
        self.startDate = startDate
        self.sensorDataList = sensorDataList
        self.endDate = endDate
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

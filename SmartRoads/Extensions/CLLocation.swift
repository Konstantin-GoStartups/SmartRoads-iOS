//
//  CLLocation.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 31.03.21.
//

import Foundation
import CoreLocation

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ street: String?,_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.thoroughfare, $0?.first?.locality,$0?.first?.country, $1) }
    }
}

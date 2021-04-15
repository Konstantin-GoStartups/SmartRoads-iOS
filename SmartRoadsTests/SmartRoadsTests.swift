//
//  SmartRoadsTests.swift
//  SmartRoadsTests
//
//  Created by Konstantin Kostadinov on 13.04.21.
//

import XCTest
import RealmSwift
@testable import SmartRoads

class SmartRoadsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        var sensorDataWrapperJson  = SensorDataWrapper()
        var sensorDatajsonFrameOne = SensorData()
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "3fps", ofType: "json") else {
            fatalError("RecordedExercise.json not found")
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathString), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            guard let json = jsonResult as? [String:Any] else { return }
            //print(json)
            let uuid = json["uuid"] as! String
            let id = json["id"] as! Int
            let depthVideoURL = json["depthVideoURL"] as! String
            let rgbVideoURL = json["rgbVideoURL"] as! String
            let jsonFileURL = json["jsonFileURL"] as! String
            let confidenceVideoURL = json["confidenceVideoURL"] as! String
            let city = json["city"] as! String
            let country = json["country"] as! String
            let startDate = json["startDate"] as! String
            let endDate = json["endDate"] as! String
            let sensorData = json["sensorDataList"] as! Array<Any>
            guard let firstSensorData = sensorData.first as? [String:Any] else { return }
            let frame = firstSensorData["frame"] as! Int
            let intrinsics = firstSensorData["intrinsics"] as! String
            let maximumDistance = firstSensorData["maximumDistance"] as! Float
            let minimumDistance = firstSensorData["minimumDistance"] as! Float
            let dataId = firstSensorData["id"] as! Int
            let xAcceleration = firstSensorData["xAcceleration"] as! Float
            let yAcceleration = firstSensorData["yAcceleration"] as! Float
            let zAcceleration = firstSensorData["zAcceleration"] as! Float
            let longitude = firstSensorData["longitude"] as! Double
            let latitude = firstSensorData["latitude"] as! Double
            let normalisedPixelData = firstSensorData["normalisedPixelData"] as! String
            let defaultPixelData = firstSensorData["defaultPixelData"] as! String
            let clampedPixelData = firstSensorData["clampedPixelData"] as! String
            let finalPixelData = firstSensorData["finalPixelData"] as! String
            let matrix = firstSensorData["matrix"] as! String
            let projectionMatrix = firstSensorData["projectionMatrix"] as! String
            let eulerAngle = firstSensorData["eulerAngle"] as! String
            let normalPixelArray = [Float(normalisedPixelData)]//normalisedPixelData as! [Float]
            let defaultPixelArray = [Float(defaultPixelData)]
           // let clampedPixelArray = [Float(clampedPixelData)]
            let finalPixelArray = [Float(finalPixelData)]
            let separatedValues = normalisedPixelData.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").wordList
            //print(separatedValues)
            var floatClampedData = [Float]()
            for separatedValue in separatedValues {
                floatClampedData.append((separatedValue as NSString).floatValue)
            }
            
            let separatedValues2 = defaultPixelData.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").wordList
            //print(separatedValues)
            var floatFinalData = [Float]()
            for separatedValue in separatedValues2 {
                floatFinalData.append((separatedValue as NSString).floatValue)
            }
            print("RAZMERI", floatClampedData.count, floatFinalData.count)
            for i in 0..<floatClampedData.count {
                var pixel = floatClampedData[i]
                pixel *= 255
                print(floatClampedData[i], pixel,floatFinalData[i])//, floatFinalData[i])
            }
            
            
            
            let comparisonPixel = finalPixelArray.first
           // //let firstPixel = clampedPixelArray.first
           // print(firstPixel, comparisonPixel)
            
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

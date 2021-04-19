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
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "3", ofType: "json") else {
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
                var pixel = floatFinalData[i]
                pixel *= 255
                pixel *= 8
                pixel *= 8
                pixel *= 8
                print(floatClampedData[i],floatFinalData[i],pixel)//, floatFinalData[i])
            }
            let image = UIImage()
            let imag2 = UIImage()
            
            guard let clampedDataBuffer = image.buffer()!.createBuffer(from: floatClampedData) else { return }
            guard let finalDataBuffer = imag2.buffer()!.createBuffer(from: floatFinalData) else { return }
            
             let clampedImage = UIImage(ciImage: CIImage(cvPixelBuffer: clampedDataBuffer))
             let finalImage = UIImage(ciImage: CIImage(cvPixelBuffer: finalDataBuffer))
            
            let clampedSubsc = clampedImage.subscriptColor(x: 0, y: 0)
            let finalSubsc = finalImage.subscriptColor(x: 0, y: 0)
            
            print(clampedSubsc?.rgba, finalSubsc?.rgba)
            
            //python3 test_depth_maps.py --depth test_data/2021_04_13_rgb+depth/DEPTH-2021_04_13-02_59-bulevard-Simeonovsko-shose-Sofia.mp4 --json test_data/2021_04_13_rgb+depth/JSON-2021_04_13-02_59-bulevard-Simeonovsko-shose-Sofia.json --frame_num 0
            
        }
    }
    
//    func createBuffer(from array: [Float]) -> CVPixelBuffer? {
//        let height = 192
//        let width = 256
//        var pixelBuffer: CVPixelBuffer?
//        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
//        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
//        for y in stride(from:0, to: height, by: 1) {
//            for x in stride(from: 0, to: width, by: 1) {
//                var pixel = floatBuffer[y * width + x]
//                pixel = array[y * width + x ]
//                floatBuffer[y * width + x] = pixel
//            }
//        }
//        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
//        return pixelBuffer
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

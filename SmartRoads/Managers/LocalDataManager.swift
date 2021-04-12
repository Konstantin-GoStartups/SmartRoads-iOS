//
//  LocalDataManager.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 29.03.21.
//

import Foundation
import RealmSwift
import CoreLocation
import AVFoundation

enum LocalDataManagerError: Error {
    case wrongQueue
}

class LocalDataManager {

    static let shared = LocalDataManager()
    static let realm: Realm = {
        return try! initializeRealm(checkForMainThread: true)
    }()

    static var backgroundRealm = {
        try! initializeRealm()
    }()

    let realmB = try! Realm(configuration: realmConfiguration)
    var backgroundRealmB: Realm? = nil
    var sensorDataWrapper: SensorDataWrapper? = nil

    private init() {}

    let realmQueue = DispatchQueue(label: "realm saving queue", qos: .userInteractive)

    class func initializeRealm(checkForMainThread: Bool = false) throws -> Realm {
           if checkForMainThread {
               guard OperationQueue.current?.underlyingQueue == DispatchQueue.main else {
                   throw LocalDataManagerError.wrongQueue
               }
           }
           do {
               return try Realm(configuration: realmConfiguration)
           } catch {
               throw error
           }
       }

    static let realmConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.schemaVersion = 1
        configuration.migrationBlock = { (migration, version) in

        }

        return configuration
    }()
    
    func initializeQueuesAndRealm() {
        realmQueue.async {
            self.backgroundRealmB = try! Realm(configuration: LocalDataManager.realmConfiguration)
        }
    }
    
    func getGpsLocation() -> [Double] {

        var gpsLocation: [Double] = []
        
        if (CLLocationManager().authorizationStatus == .authorizedWhenInUse ||
                CLLocationManager().authorizationStatus == .authorizedAlways) {
            if let coordinate = CLLocationManager().location?.coordinate {
                gpsLocation = [coordinate.latitude, coordinate.longitude]
            }
        }
        
        return gpsLocation
    }
    
    func createDataWrapper(startDate: String) {
        realmQueue.async { [self] in
            let rm = try! Realm(configuration: LocalDataManager.realmConfiguration, queue: realmQueue)
            try! rm.write {
                self.sensorDataWrapper = SensorDataWrapper()
                self.sensorDataWrapper?.startDate = startDate
                self.sensorDataWrapper?.id = (rm.objects(SensorDataWrapper.self).max(ofProperty: "id") as Int? ?? 0) + 1
                rm.add((self.sensorDataWrapper)!, update: .all)
            }
        }
    }
    
    func addVideoPaths(rgbPath: String, depthPath: String, confidencePath: String, uuid: String, street: String, city: String, country: String){
        realmQueue.async {
            autoreleasepool {
                let rm = try! Realm(configuration: LocalDataManager.realmConfiguration, queue: self.realmQueue)
                try! rm.write {
                    let sensorData = SensorDataWrapper(value: self.sensorDataWrapper)
                    sensorData.rgbVideoURL = rgbPath
                    sensorData.depthVideoURL = depthPath
                    sensorData.confidenceVideoURL = confidencePath
                    sensorData.city = city
                    sensorData.street = street
                    sensorData.country = country
                    sensorData.uuid = uuid
                    rm.add((sensorData), update: .all)
                    self.sensorDataWrapper = sensorData
                }
            }
        }
    }
    
    func addDataToObjects(frames: Int, coordinates: [Double], xAcceleration: Double, yAcceleration: Double, zAcceleration: Double, matrix: String, intrinsics: String, projectionMatrix: String, eulerAngle: String, minimumDistance: Float, maximumDistance: Float, defaultPixelData: String, normalisedPicelData: String, clampedPixelData: String, finalPixelData: String) {
        realmQueue.async { [self] in
            autoreleasepool {
                let rm = try! Realm(configuration: LocalDataManager.realmConfiguration, queue: realmQueue)
                try! rm.write {
                    let sensorData = SensorData(frame: frames, latitude: coordinates.first ?? 0.0, longitude: coordinates.last ?? 0.0, xAcceleration: xAcceleration, yAcceleration: yAcceleration, zAcceleration: yAcceleration, matrix: matrix, intrinsics: intrinsics, projectionMatrix: projectionMatrix, eulerAngle: eulerAngle, minimumDistance: minimumDistance, maximumDistance: maximumDistance, defaultPixelData: defaultPixelData, normalisedPixelData: normalisedPicelData, clampedPixelData: clampedPixelData, finalPixelData: finalPixelData)
                    sensorData.id = (rm.objects(SensorData.self).max(ofProperty: "id") as Int? ?? 0) + 1
                    rm.add(sensorData, update: .all)
                    self.sensorDataWrapper?.sensorDataList.append(sensorData)
                    rm.add(sensorDataWrapper!, update: .all)
                    print("saved")
                }
            }
        }
    }
    
    func saveDataWrapper(endDate: String) {
        realmQueue.async { [self] in
            autoreleasepool {
                let rm = try! Realm(configuration: LocalDataManager.realmConfiguration, queue: self.realmQueue)
                try! rm.write {
                    print("SAving json")
                    self.sensorDataWrapper?.endDate = endDate
                    let uuid = self.sensorDataWrapper?.uuid ?? ""
                    let jsonFileURL = getDocumentsDirectory().appendingPathComponent(uuid).appendingPathComponent("JSON-\(uuid)").appendingPathExtension("json")
                    sensorDataWrapper?.jsonFileURL = "\(jsonFileURL)".replacingOccurrences(of: "file://", with: "")
                    let dict2 = self.sensorDataWrapper!.toDictionary2()
                    let data = try! (dict2 as Dictionary).toJson()
                    try! data.description.write(to: jsonFileURL, atomically: true, encoding: .utf8)
                    self.movFileTransformToMp4WithSourceUrl(sourceUrl: URL(fileURLWithPath: sensorDataWrapper!.rgbVideoURL))
                    rm.add(sensorDataWrapper!, update: .all)
                    print("JSON saved")
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func movFileTransformToMp4WithSourceUrl(sourceUrl: URL) {
                     // Name the file with the current time
            let date = Date()
            let formatter = DateFormatter.init()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let fileName = formatter.string(from: date) + ".mp4"
            
                     // Save the address sandbox path
            let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
            let videoSandBoxPath = (docPath as String) + "/ablumVideo" + fileName
            
            print(videoSandBoxPath)
            
                     //  Transcoding configuration
            let avAsset = AVURLAsset.init(url: sourceUrl, options: nil)
     
                     // Take the video time and process for uploading
            let time = avAsset.duration
            let number = Float(CMTimeGetSeconds(time)) - Float(Int(CMTimeGetSeconds(time)))
            let totalSecond = number > 0.5 ? Int(CMTimeGetSeconds(time)) + 1 : Int(CMTimeGetSeconds(time))
            let photoId = String(totalSecond)
            
            
            let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPreset640x480)
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.outputURL = URL.init(fileURLWithPath: videoSandBoxPath)
        exportSession?.outputFileType = AVFileType.mp4 //Control the format of the transcoding
            exportSession?.exportAsynchronously(completionHandler: {
                if exportSession?.status == AVAssetExportSession.Status.failed {
                                     print("transcode failed")
                }
                if exportSession?.status == AVAssetExportSession.Status.completed {
                                     print("transcode success")
                                     // After the transcoding is successful, you can use the dataurl to get the video data for uploading.
                    let dataurl = URL.init(fileURLWithPath: videoSandBoxPath)
                                       // Upload a video, you need to upload a video cover image at the same time, here is a way to get a screenshot of the video cover, the method is implemented below
                    //let image = getVideoCropPicture(videoUrl: sourceUrl)
                }
            })
        }
}

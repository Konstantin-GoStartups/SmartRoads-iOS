//
//  Recorder.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import CoreMedia

protocol Recorder {
    associatedtype T
    
    func prepareForRecording(dirPath: String, filename: String, fileExtension: String)
    func update(_: T, timestamp: CMTime?)
    func finishRecording()
}

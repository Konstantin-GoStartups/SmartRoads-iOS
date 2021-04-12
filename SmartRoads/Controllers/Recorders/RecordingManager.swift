//
//  RecordingManager.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import Foundation

protocol RecordingManager {
    var isRecording: Bool { get }
    
    func getSession() -> NSObject
    
    func startRecording(username: String, sceneDescription: String, sceneType: String)
    func stopRecording()
}

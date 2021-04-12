//
//  CondidenceRecorder.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 2.04.21.
//

import Foundation

//
//  DepthRecorder.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import AVFoundation
import Foundation
import Accelerate.vImage
import Compression
import CoreMedia
import CoreVideo

class ConfidenceRecorder: Recorder {
    typealias T = CVPixelBuffer
    
    // I'm not sure if a separate queue is necessary
    private let movieQueue = DispatchQueue(label: "confidence queue")
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    //    private var videoTransform: CGAffineTransform
    private var videoSettings: [String: Any]
    
    //    private(set) var isRecording = false
    
    private var count: Int32 = 0
    
    init(videoSettings: [String: Any]) {
        self.videoSettings = videoSettings
    }
    
    func prepareForRecording(dirPath: String, filename: String, fileExtension: String = "mp4") {
        
        movieQueue.async {
            
            self.count = 0
            
            let outputFilePath = (dirPath as NSString).appendingPathComponent((filename as NSString).appendingPathExtension(fileExtension)!)
            let outputFileUrl = URL(fileURLWithPath: outputFilePath)
            
            guard let assetWriter = try? AVAssetWriter(url: outputFileUrl, fileType: .mp4) else {
                print("Failed to create AVAssetWriter.")
                return
            }
            
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: self.videoSettings)
            
            let assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: nil)
            
            assetWriterVideoInput.expectsMediaDataInRealTime = true
            assetWriter.add(assetWriterVideoInput)
            
            self.assetWriter = assetWriter
            self.assetWriterVideoInput = assetWriterVideoInput
            self.assetWriterInputPixelBufferAdaptor = assetWriterInputPixelBufferAdaptor
        }
        
    }
    
    func update(_ buffer: CVPixelBuffer, timestamp: CMTime?) {
        
        guard let timestamp = timestamp else {
            return
        }
        
        movieQueue.async {
            
            guard let assetWriter = self.assetWriter else {
                print("Error! assetWriter not initialized.")
                return
            }
            
            print("Saving video frame \(self.count) ...")
            
            if assetWriter.status == .unknown {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: timestamp)
                
                if let adaptor = self.assetWriterInputPixelBufferAdaptor {

                    while !adaptor.assetWriterInput.isReadyForMoreMediaData {
                        print("Waiting for assetWriter...")
                        usleep(10)
                    }
                  adaptor.append(buffer, withPresentationTime: timestamp)
                  //self.saveBuffer(buffer, timestamp: timestamp, adaptor: adaptor)
                }
                
            } else if assetWriter.status == .writing {
                                
                if let adaptor = self.assetWriterInputPixelBufferAdaptor, adaptor.assetWriterInput.isReadyForMoreMediaData {
                  //self.saveBuffer(buffer, timestamp: timestamp, adaptor: adaptor)
                  adaptor.append(buffer, withPresentationTime: timestamp)
                }
            }
            
            self.count += 1
        }
    }
    
    func update(buffer: CMSampleBuffer) {
        
        movieQueue.async {
            
            guard let assetWriter = self.assetWriter else {
                print("Error! assetWriter not initialized.")
                return
            }
            
            if assetWriter.status == .unknown {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
            } else if assetWriter.status == .writing {
                if let input = self.assetWriterVideoInput, input.isReadyForMoreMediaData {
                    input.append(buffer)
                }
            }
        }
    }
    
    func finishRecording() {
        
        movieQueue.async {
            
            guard let assetWriter = self.assetWriter else {
                print("Error!")
                return
            }
            
            self.assetWriter = nil
            
            assetWriter.finishWriting {
                print("Finished writing video.")
            }
        }
    }
}

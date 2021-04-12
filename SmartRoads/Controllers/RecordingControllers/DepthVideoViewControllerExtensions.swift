//
//  DepthVideoViewControllerExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import UIKit
import AVFoundation
import ARKit
import Photos
import CoreLocation
import CoreMotion
import CoreGraphics
import Realm

extension DepthVideoViewController: ARSCNViewDelegate {
}

extension DepthVideoViewController: ARSessionDelegate {
        
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        guard let depthData = frame.sceneDepth else {
//            return
//        }

        guard let depthData = session.currentFrame?.sceneDepth else { return }
        let depthMap: CVPixelBuffer = depthData.depthMap
        let arrayOfPixels = depthMap.normalize()
       // print(asdasd)
        guard let colorImage: CVPixelBuffer = arView.session.currentFrame?.capturedImage else { return }
        let clampedPixels = depthMap.clamp()
        guard let confidenceMap = depthData.confidenceMap else {
            print("Failed to get confidenceMap.")
            return
        }
        lastDepthMap = depthMap

        let defaultDepthPixels = arrayOfPixels.first!.debugDescription
        let normalisedDepthPixels = arrayOfPixels.last!.debugDescription
        let clampedDepthPixels = clampedPixels.debugDescription
        self.previewView.image = UIImage(ciImage: CIImage(cvPixelBuffer: depthMap))
        let intrinsics = session.currentFrame?.camera.intrinsics.debugDescription.replacingOccurrences(of: "simd_float3x3(", with: "").replacingOccurrences(of: ")", with: "") ?? "error"
        let matrix = session.currentFrame?.camera.viewMatrix(for: .landscapeLeft).debugDescription.replacingOccurrences(of: "simd_float4x4(", with: "").replacingOccurrences(of: ")", with: "") ?? "error"
        let projectionMatrix = session.currentFrame?.camera.projectionMatrix.debugDescription.replacingOccurrences(of: "simd_float4x4(", with: "").replacingOccurrences(of: ")", with: "") ?? "error"
        let eulerAnglesMatrix = session.currentFrame?.camera.eulerAngles.debugDescription.replacingOccurrences(of: "SIMD3<Float>", with: "").replacingOccurrences(of: ")", with: "") ?? "error"
        if self.isRecording {
            cycles += 1
        }
        if self.isRecording && (cycles%devider == 0){
            let image = UIImage(ciImage: CIImage(cvPixelBuffer: depthMap))
            guard let okok = image.buffer() else { return }
            let timestamp: CMTime = CMTime(seconds: frame.timestamp, preferredTimescale: 1_000_000_000)
            guard let depthPixelBuffer = self.previewView.image?.buffer() else { return }
            let finalPixels = depthPixelBuffer.finalPixels().debugDescription
            //            if let image =  UIImage(ciImage: CIImage(cvImageBuffer: colorImage)).rotate(radians: .pi/2) {
            //                if let rgbPixelBuffer = image.buffer() {
            //                    self.rgbRecorder.update(rgbPixelBuffer, timestamp: timestamp)
            //                } else {
            //                    self.rgbRecorder.update(colorImage, timestamp: timestamp)
            //                }
            //            } else {
            self.rgbRecorder.update(colorImage, timestamp: timestamp)
            //     }
            self.depthRecorder.update(okok, timestamp: timestamp)
            //self.confidenceRecorder.update(confidencePixelBuffer, timestamp: timestamp)
            let coordinates = self.getGpsLocation(locationManager: self.locationManager)
            guard let data = self.motionManager.accelerometerData else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            self.localDataManager.addDataToObjects(frames: self.numFrames, coordinates: coordinates, xAcceleration: x, yAcceleration: y, zAcceleration: z, matrix: matrix, intrinsics: intrinsics, projectionMatrix: projectionMatrix, eulerAngle: eulerAnglesMatrix, minimumDistance: arrayOfPixels.first?.min() ?? 0.0, maximumDistance: arrayOfPixels.first?.max() ?? 0.0, defaultPixelData: defaultDepthPixels, normalisedPicelData: normalisedDepthPixels, clampedPixelData: clampedDepthPixels, finalPixelData: finalPixels)
            self.numFrames += 1
        }
    }
    
    func makeTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        var texture: CVMetalTexture? = nil
        guard let textureCache = textureCache else { return nil }
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
        
        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }
    
    func makeTextureCache() -> CVMetalTextureCache? {
        // Create captured image texture cache
        var cache: CVMetalTextureCache!
        guard let device: MTLDevice = MTLCreateSystemDefaultDevice() else { return nil}

        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        
        return cache
    }
    
    func asdasdasd(imageBuffer: CVPixelBuffer) -> UIImage? {

            // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0));

            // Get the number of bytes per row for the pixel buffer
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

            // Get the number of bytes per row for the pixel buffer
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);

            // Get the pixel buffer width and height
            let width = CVPixelBufferGetWidth(imageBuffer);
            let height = CVPixelBufferGetHeight(imageBuffer);

            // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB();//CGColorSpaceCreateDeviceCMYK()//CGColorSpaceCreateDeviceGray()//CGColorSpaceCreateDeviceRGB();

            // Create a bitmap graphics context with the sample buffer data
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        //CGBitmapContextCreate(baseAddress, width, height, 8,bytesPerRow, colorSpace, CGBitmapInfo.byteOrder32Little | CGImageAlphaInfo.premultipliedFirst);

            // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage();

            // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));

            // Free up the context and color space
            //CGContextRelease(context);
           // CGColorSpaceRelease(colorSpace);

            // Create an image object from the Quartz image
        guard let qImage = quartzImage else { return nil }
        let image = UIImage(cgImage: qImage)

            // Release the Quartz image
            //CGImageRelease(quartzImage);

            return image
    }
    
    func imageCreation(from texture: MTLTexture) -> UIImage? {
        let bytesPerPixel = 4

        // The total number of bytes of the texture
        let imageByteCount = texture.width * texture.height * bytesPerPixel

        // The number of bytes for each image row
        let bytesPerRow = texture.width * bytesPerPixel

        // An empty buffer that will contain the image
        var src = [UInt8](repeating: 0, count: Int(imageByteCount))

        // Gets the bytes from the texture
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        texture.getBytes(&src, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)

        // Creates an image context
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &src, width: texture.width, height: texture.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        // Creates the image from the graphics context
        guard let dstImage = context?.makeImage() else { return nil }

        // Creates the final UIImage
        return UIImage(cgImage: dstImage, scale: 0.0, orientation: .up)
    }
}

// MARK: - Helper Methods
extension DepthVideoViewController {
    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .unspecified) else {
            fatalError("No depth video camera available")
        }
        
        session.sessionPreset = .photo
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        let depthOutput = AVCaptureDepthDataOutput()
        depthOutput.setDelegate(self, callbackQueue: dataOutputQueue)
        depthOutput.isFilteringEnabled = true
        session.addOutput(depthOutput)
        
        let depthConnection = depthOutput.connection(with: .depthData)
        depthConnection?.videoOrientation = .portrait
        
        let outputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let videoRect = videoOutput
            .outputRectConverted(fromMetadataOutputRect: outputRect)
        let depthRect = depthOutput
            .outputRectConverted(fromMetadataOutputRect: outputRect)
        
        scale =
            max(videoRect.width, videoRect.height) /
            max(depthRect.width, depthRect.height)
        
        do {
            try camera.lockForConfiguration()
            
            if let format = camera.activeDepthDataFormat,
               let range = format.videoSupportedFrameRateRanges.first  {
                camera.activeVideoMinFrameDuration = range.minFrameDuration
            }
            
            camera.unlockForConfiguration()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}


// MARK: - Capture Video Data Delegate Methods
extension DepthVideoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let image = CIImage(cvPixelBuffer: pixelBuffer!)
        
        let previewImage: CIImage
        
        switch (previewMode, filter, mask) {
        case (.original, _, _):
            previewImage = image
        case (.depth, _, _):
            previewImage = depthMap ?? image
        case (.mask, _, let mask?):
            previewImage = mask
        case (.filtered, .comic, let mask?):
            previewImage = depthFilters.comic(image: image, mask: mask)
        case (.filtered, .greenScreen, let mask?):
            previewImage = depthFilters.greenScreen(image: image,
                                                    background: background,
                                                    mask: mask)
        case (.filtered, .blur, let mask?):
            previewImage = depthFilters.blur(image: image, mask: mask)
        default:
            previewImage = image
        }
        
        let displayImage = UIImage(ciImage: previewImage)
        DispatchQueue.main.async { [weak self] in
            self?.previewView.image = displayImage
        }
    }
}

// MARK: - Slider Methods
extension DepthVideoViewController {
}

// MARK: - Segmented Control Methods
extension DepthVideoViewController {
}

// MARK: - Capture Depth Data Delegate Methods
extension DepthVideoViewController: AVCaptureDepthDataOutputDelegate {
    func depthDataOutput(_ output: AVCaptureDepthDataOutput,
                         didOutput depthData: AVDepthData,
                         timestamp: CMTime,
                         connection: AVCaptureConnection) {
        guard previewMode != .original else {
            return
        }
        
        var convertedDepth: AVDepthData
        
        let depthDataType = kCVPixelFormatType_DisparityFloat32
        if depthData.depthDataType != depthDataType {
            convertedDepth = depthData.converting(toDepthDataType: depthDataType)
        } else {
            convertedDepth = depthData
        }
        
        let pixelBuffer = convertedDepth.depthDataMap
        pixelBuffer.clamp()
        
        
        let width = CVPixelBufferGetWidth(pixelBuffer) //768 on an iPhone 7+
        let height = CVPixelBufferGetHeight(pixelBuffer) //576 on an iPhone 7+
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Convert the base address to a safe pointer of the appropriate type
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(pixelBuffer), to: UnsafeMutablePointer<Float32>.self)
        print(floatBuffer)
        
        let depthMap = CIImage(cvPixelBuffer: lastDepthMap ?? pixelBuffer)
        
        if previewMode == .mask || previewMode == .filtered {
            switch filter {
            case .comic:
                mask = depthFilters.createHighPassMask(for: depthMap,
                                                       withFocus: sliderValue,
                                                       andScale: scale)
            case .greenScreen:
                mask = depthFilters.createHighPassMask(for: depthMap,
                                                       withFocus: sliderValue,
                                                       andScale: scale,
                                                       isSharp: true)
            case .blur:
                mask = depthFilters.createBandPassMask(for: depthMap,
                                                       withFocus: sliderValue,
                                                       andScale: scale)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.depthMap = depthMap
        }
    }
    
//    func getPoints(avDepthData: AVDepthData) -> Array<Any> {
//            let depthData = avDepthData.converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
//            guard let intrinsicMatrix = avDepthData.cameraCalibrationData?.intrinsicMatrix/*,
//                let depthDataMap = rectifyDepthData(avDepthData: depthData) */else {
//                return []
//            }
//            let depthDataMap = depthData.depthDataMap
//            CVPixelBufferLockBaseAddress(depthDataMap, CVPixelBufferLockFlags(rawValue: 0))
//           
//            let width = CVPixelBufferGetWidth(depthDataMap)
//            let height = CVPixelBufferGetHeight(depthDataMap)
//           
//            var points = Array<Any>()
//            let focalX = Float(width) * (intrinsicMatrix[0][0] / 480)
//            let focalY = Float(height) * ( intrinsicMatrix[1][1] / 640)
//            let principalPointX = Float(width) * (intrinsicMatrix[2][0] / 480)
//            let principalPointY = Float(height) * (intrinsicMatrix[2][1] / 640)
//            for y in 0 ..< height{
//                for x in 0 ..< width{
//                    guard let Z = getDistance(at: CGPoint(x: x, y: y) , depthMap: depthDataMap, depthWidth: width, depthHeight: height) else {
//                        continue
//                    }
//                   
//                    let X = (Float(x) - principalPointX) * Z / focalX
//                    let Y = (Float(y) - principalPointY) * Z / focalY
//                    points.append(PointXYZ(x: X, y: Y, z: Z))
//                }
//            }
//            CVPixelBufferUnlockBaseAddress(depthDataMap, CVPixelBufferLockFlags(rawValue: 0))
//           
//            return points
//        }
}

extension DepthVideoViewController: RecordingManager {
    
    func getSession() -> NSObject {
        return NSObject()
    }
    
    func startRecording(username: String, sceneDescription: String, sceneType: String) {
        
        sessionQueue.async { [self] in
            
            self.username = username
            self.sceneDescription = sceneDescription
            self.sceneType = sceneType
            
            numFrames = 0
            
            // TODO: consider an if check here to avoid doing this for every recording?
            if let currentFrame = arSession.currentFrame {
                cameraIntrinsic = currentFrame.camera.intrinsics
                
                // get depth resolution
                if let depthData = currentFrame.sceneDepth {
                    
                    let depthMap: CVPixelBuffer = depthData.depthMap
                    let height = CVPixelBufferGetHeight(depthMap)
                    let width = CVPixelBufferGetWidth(depthMap)
                    
                    depthFrameResolution = [height, width]
                    
                } else {
                    print("Unable to get depth resolution.")
                }
                
            }
            
            print("pre1 count: \(numFrames)")
            
            let coordinates = self.getGpsLocation(locationManager: self.locationManager)
            let location = CLLocation(latitude: coordinates.first ?? 0.0, longitude: coordinates.last ?? 0.0)
            location.fetchCityAndCountry { (street,city, country, error)  in
                if let error = error {
                    print("LocalizationErrorrr")
                }
                let formatter3 = DateFormatter()
                formatter3.dateFormat = "yyyy:MM:dd" // hh:mm
                print(formatter3.string(from: Date()))
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "hh:mm"
                print(formatter1.string(from: Date()))
                recordingId = "\(formatter3.string(from: Date()))-\(formatter1.string(from: Date()))-\(street?.replacingOccurrences(of: " ", with: "-") ?? "")-\(city ?? "")"
                //recordingId = "\(UUID())"
                dirUrl = URL(fileURLWithPath: getRecordingDataDirectoryPath(recordingId: recordingId))
                let rgbOutputFilePath = (dirUrl.path as NSString).appendingPathComponent(("RGB-\(recordingId)" as NSString).appendingPathExtension("mp4")!)
                let depthOutputFilePath = (dirUrl.path as NSString).appendingPathComponent(("DEPTH-\(recordingId)" as NSString).appendingPathExtension("mp4")!)
                let confidenceOutputFilePath = (dirUrl.path as NSString).appendingPathComponent(("CONFIDENCE-\(recordingId)" as NSString).appendingPathExtension("mp4")!)
    //            let rgbOutputFilePath = "Documents/\(recordingId)/RGB-\(recordingId).mp4"
    //            let depthOutputFilePath = "Documents/\(recordingId)/DEPTH-\(recordingId).mp4"
                rgbRecorder.prepareForRecording(dirPath: dirUrl.path, filename: "RGB-\(recordingId)")
                depthRecorder.prepareForRecording(dirPath: dirUrl.path, filename: "DEPTH-\(recordingId)")
                //confidenceRecorder.prepareForRecording(dirPath: dirUrl.path, filename: "CONFIDENCE-\(recordingId)")
                isRecording = true
                
                print("pre2 count: \(numFrames)")
               // realmQueue.async {
               // DispatchQueue.main.async {
                self.localDataManager.addVideoPaths(rgbPath: rgbOutputFilePath, depthPath: depthOutputFilePath, confidencePath: confidenceOutputFilePath, uuid: recordingId, street: street ?? "",city: city ?? "",country: country ?? "")
            }
            
            //}
        }
        
    }
    func getRecordingDataDirectoryPath(recordingId: String) -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        // create new directory for new recording
        let documentsDirectoryUrl = URL(string: documentsDirectory)!
        let recordingDataDirectoryUrl = documentsDirectoryUrl.appendingPathComponent(recordingId)
        if !FileManager.default.fileExists(atPath: recordingDataDirectoryUrl.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: recordingDataDirectoryUrl.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        let recordingDataDirectoryPath = recordingDataDirectoryUrl.absoluteString
        return recordingDataDirectoryPath
    }
    
    func stopRecording() {
        
        sessionQueue.sync { [self] in
            
            print("post count: \(numFrames)")
            
            isRecording = false
            
            //depthRecorder.finishRecording()
            //confidenceMapRecorder.finishRecording()
            rgbRecorder.finishRecording()
            depthRecorder.finishRecording()
            //cameraInfoRecorder.finishRecording()
            
            //writeMetadataToFile()
            self.numFrames = 0
            username = nil
            sceneDescription = nil
            sceneType = nil
            
        }
    }
}

extension DepthVideoViewController {
    private func sendActivity(videoUrl: URL){
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [ videoUrl ], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.button
            self.present(activityViewController, animated: true, completion: nil)
            self.isRecording = false
        }
    }
}




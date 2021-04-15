//
//  CVPixelBufferExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import CoreVideo
import UIKit

extension CVPixelBuffer {
    func createBuffer(from array: [Float]) {
        let height = 192
        let width = 256
        var pixelBuffer: CVPixelBuffer?
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        for y in stride(from:0, to: height, by: 1) {
            for x in stride(from: 0, to: width, by: 1) {
                var pixel = floatBuffer[y * width + x]
                pixel = array[y * width + x ]
                floatBuffer[y * width + x] = pixel
            }
        }
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    }
    func finalPixels() -> [Float] {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        var finalPixels = [Float]()
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        for y in stride(from: 0, to: height, by: 1) {
            for x in stride(from: 0, to: width, by: 1) {
                finalPixels.append(floatBuffer[y * width + x])
            }
        }
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        return finalPixels
    }
    
    func clamp() -> [Float] {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        var clampedPixels = [Float]()
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        for y in stride(from: 0, to: height, by: 1) {
            for x in stride(from: 0, to: width, by: 1) {
                let pixel = floatBuffer[y * width + x]
                floatBuffer[y * width + x] = min(1.0, max(pixel, 0.0))
                clampedPixels.append(floatBuffer[y * width + x])
            }
        }
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        return clampedPixels
    }
    
    func normalize() -> [[Float]] {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        var minPixel: Float = 1.0
        var maxPixel: Float = 0.0
        var pixels = [Float]()
        var normalizedPixels = [Float]()
        /// You might be wondering why the for loops below use `stride(from:to:step:)`
        /// instead of a simple `Range` such as `0 ..< height`?
        /// The answer is because in Swift 5.1, the iteration of ranges performs badly when the
        /// compiler optimisation level (`SWIFT_OPTIMIZATION_LEVEL`) is set to `-Onone`,
        /// which is eactly what happens when running this sample project in Debug mode.
        /// If this was a production app then it might not be worth worrying about but it is still
        /// worth being aware of.
        
        
        
        for y in stride(from: 0, to: height, by: 1) {
            //print(y)
            for x in stride(from: 0, to: width, by: 1) {
                let pixel = floatBuffer[y * width + x]
                pixels.append(pixel)//.round(to: 2))
                minPixel = min(pixel, minPixel)
                maxPixel = max(pixel, maxPixel)
            }
        }
        
        
        let range = maxPixel - minPixel
        for y in stride(from: 0, to: height, by: 1) {
            for x in stride(from: 0, to: width, by: 1) {
                let pixel = floatBuffer[y * width + x]
                floatBuffer[y * width + x] = (pixel - minPixel) / range
                normalizedPixels.append(floatBuffer[y*width+x])//.round(to: 2))
            }
        }
        //
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        return [pixels,normalizedPixels]//[pixels.min() ?? 0.0, pixels.max() ?? 0.0, range]
    }
}

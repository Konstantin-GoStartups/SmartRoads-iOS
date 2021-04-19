//
//  UIImageExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import UIKit
import VideoToolbox

extension CIImage{
    func buffer() -> CVPixelBuffer? {
        let context = CIContext()
        guard let pixelBuffer = self.pixelBuffer else { return nil}
        context.render(self, to: pixelBuffer)
        return pixelBuffer
    }
}


public func avarage<S: Collection>(
    _ sequence: S)
    -> S.Element where S.Element: FixedWidthInteger {
        return sequence.reduce(0, +) / S.Element(sequence.count)
}
 
extension UInt16 {
    var uint8: UInt8 {
        return UInt8(self)
    }
}
 
extension UInt8 {
    var uint16: UInt16 {
        return UInt16(self)
    }
}


extension UIImage {
    
    func subscriptColor (x: Int, y: Int) -> UIColor? {
        
        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return nil
        }
        
        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)
        
        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
        
        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func graySacled() -> UIImage? {
            
            guard
                let cgImage = cgImage,
                let data = cgImage.dataProvider?.data as Data? else {
                    return nil
            }
            
            let width = cgImage.width
            let height = cgImage.height
            let channels = 4
            let size = data.count / channels
            
            let buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: size)
            defer { free(buffer) }
     
            stride(from: 0, to: data.count, by: channels).forEach {
                /// Here the gray uses the simplest algorithm `G = (R + G + B) / 3`
                buffer.advanced(by: $0 / channels).pointee = avarage(($0..<$0 + 3).map { data[$0].uint16 }).uint8
            }
                     /// =================== buffer is already `single channel ``gray`, the following is a composite image ============= ======
            
            let releaseData: CGDataProviderReleaseDataCallback = {
                (info, buffer, length) in
            }
            
            return CGDataProvider(
                    dataInfo: nil,
                    data: buffer,
                    size: size,
                    releaseData: releaseData)
                .flatMap {
                    CGImage(
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bitsPerPixel: 8,
                    bytesPerRow: width,
                    space: CGColorSpaceCreateDeviceGray(),
                    bitmapInfo: CGBitmapInfo(rawValue: 0),
                    provider: $0,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent)
                }
                .flatMap(UIImage.init)
     
        }

    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let image = cgImage else {
            return nil
        }
        
        self.init(cgImage: image)
    }
    
    func convertToGrayScaleNoAlpha() -> CGImage? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let colorSpace = CGColorSpaceCreateDeviceGray();
        //let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)//CGBitmapInfo(CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)//CGBitmapContextCreate(nil, UInt(size.width), UInt(size.height), 8, 0, colorSpace, bitmapInfo)
        //CGContextDrawImage(context, , self.cgImage)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return context!.makeImage()!
    }


        /**
            Return a new image in shades of gray + alpha
        */
//         func convertToGrayScale() -> UIImage {
//
//            let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.Only.rawValue)
//            let context = CGBitmapContextCreate(nil, UInt(size.width), UInt(size.height), 8, 0, nil, bitmapInfo)
//            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
//            let mask = CGBitmapContextCreateImage(context)
//            return UIImage(CGImage: CGImageCreateWithMask(convertToGrayScaleNoAlpha(), mask), scale: scale, orientation:imageOrientation)!
//        }
    
//    func pixelBufferGray(width: Int, height: Int) -> CVPixelBuffer? {
//        return pixelBuffer(width: width, height: height,
//                           pixelFormatType: kCVPixelFormatType_OneComponent8,
//                           colorSpace: CGColorSpaceCreateDeviceGray(),
//                           alphaInfo: .none)
//    }
//
//
//    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
//                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
//        var maybePixelBuffer: CVPixelBuffer?
//        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
//        let status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                         width,
//                                         height,
//                                         pixelFormatType,
//                                         attrs as CFDictionary,
//                                         &maybePixelBuffer)
//
//        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
//            return nil
//        }
//
//        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
//
//        guard let context = CGContext(data: pixelData,
//                                      width: width,
//                                      height: height,
//                                      bitsPerComponent: 8,
//                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
//                                      space: colorSpace,
//                                      bitmapInfo: alphaInfo.rawValue)
//        else {
//            return nil
//        }
//
//        UIGraphicsPushContext(context)
//        context.translateBy(x: 0, y: CGFloat(height))
//        context.scaleBy(x: 1, y: -1)
//        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
//        UIGraphicsPopContext()
//
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        return pixelBuffer
//    }
    
//    public func pixelBufferGray() -> CVPixelBuffer? {
//        let width = self.size.width
//        let height = self.size.height
//            var pixelBuffer : CVPixelBuffer?
//            let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
//
//        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(height), kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
//
//            guard status == kCVReturnSuccess, let imageBuffer = pixelBuffer else {
//                return nil
//            }
//
//            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
//
//            let imageData =  CVPixelBufferGetBaseAddress(imageBuffer)
//
//            guard let context = CGContext(data: imageData, width: Int(width), height:Int(height),
//                                          bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(imageBuffer),
//                                          space: CGColorSpaceCreateDeviceGray(),
//                                          bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
//                                            return nil
//            }
//
//            context.translateBy(x: 0, y: CGFloat(height))
//            context.scaleBy(x: 1, y: -1)
//
//            UIGraphicsPushContext(context)
//            self.draw(in: CGRect(x:0, y:0, width: width, height: height) )
//            UIGraphicsPopContext()
//            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
//
//            return imageBuffer
//
//        }
    public func pixelBufferGray() -> CVPixelBuffer? {
        return pixelBuffer(width: Int(self.size.width), height: Int(self.size.height),
                              pixelFormatType: kCVPixelFormatType_OneComponent8,
                              colorSpace: CGColorSpaceCreateDeviceGray(),
                              alphaInfo: .none)
     }

     /**
       Resizes the image to `width` x `height` and converts it to a `CVPixelBuffer`
       with the specified pixel format, color space, and alpha channel.
     */
     public func pixelBuffer(width: Int, height: Int,
                             pixelFormatType: OSType,
                             colorSpace: CGColorSpace,
                             alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
        var maybePixelBuffer: CVPixelBuffer?
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                         kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
            let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                             width,
                                             height,
                                             pixelFormatType,
                                             attrs as CFDictionary,
                                             &maybePixelBuffer)

            guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
              return nil
            }

            let flags = CVPixelBufferLockFlags(rawValue: 0)
            guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
              return nil
            }
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }

            guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                          width: width,
                                          height: height,
                                          bitsPerComponent: 8,
                                          bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                          space: colorSpace,
                                          bitmapInfo: alphaInfo.rawValue)
            else {
              return nil
            }

            UIGraphicsPushContext(context)
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            UIGraphicsPopContext()

            return pixelBuffer
     }
    func buffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
       // let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let dataBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(pixelBuffer!), to: UnsafeMutablePointer<UInt32>.self)

        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: dataBuffer, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

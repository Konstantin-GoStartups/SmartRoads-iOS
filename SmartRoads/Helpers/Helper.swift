//
//  Helper.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 1.04.21.
//

import Foundation
import AVFoundation

class Helper {
    class func calculateDurationforVideoAt(_ url: URL) -> String {
        let duration = AVURLAsset(url: url).duration.seconds
        print(duration)
        let time: String
        if duration > 3600 {
            time = String(format:"%dh %dm %ds",
                          Int(duration/3600),
                          Int((duration/60).truncatingRemainder(dividingBy: 60)),
                          Int(duration.truncatingRemainder(dividingBy: 60)))
        } else {
            time = String(format:"%dm %ds",
                          Int((duration/60).truncatingRemainder(dividingBy: 60)),
                          Int(duration.truncatingRemainder(dividingBy: 60)))
        }
        return "Duration: \(time)"
    }
    
    class func calculateSizeOfObjectAt(_ url: URL) -> String {
        do {
            let resources = try url.resourceValues(forKeys:[.fileSizeKey])
            let fileSize = resources.fileSize ?? 0
            return fileSize.sizeToDisplay()
        } catch {
            print("error")
            return ""
        }
    }
}

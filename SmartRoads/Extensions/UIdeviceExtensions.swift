//
//  UIdeviceExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 31.03.21.
//

import Foundation
import UIKit

extension UIDevice {
    func totalDiskSpaceInBytes() -> Int64 {
        do {
            guard let totalDiskSpaceInBytes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[FileAttributeKey.systemSize] as? Int64 else {
                return 0
            }
            return totalDiskSpaceInBytes
        } catch {
            return 0
        }
    }

    func freeDiskSpaceInBytes() -> Int64 {
        do {
            guard let totalDiskSpaceInBytes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[FileAttributeKey.systemFreeSize] as? Int64 else {
                return 0
            }
            return totalDiskSpaceInBytes
        } catch {
            return 0
        }
    }

    func usedDiskSpaceInBytes() -> Int64 {
        return totalDiskSpaceInBytes() - freeDiskSpaceInBytes()
    }

    func totalDiskSpace() -> String {
        let diskSpaceInBytes = totalDiskSpaceInBytes()
        if diskSpaceInBytes > 0 {
            return ByteCountFormatter.string(fromByteCount: diskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
        return "The total disk space on this device is unknown"
    }

    func freeDiskSpace() -> String {
        let freeSpaceInBytes = freeDiskSpaceInBytes()
        if freeSpaceInBytes > 0 {
            return ByteCountFormatter.string(fromByteCount: freeSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
        return "The free disk space on this device is unknown"
    }

    func usedDiskSpace() -> String {
        let usedSpaceInBytes = totalDiskSpaceInBytes() - freeDiskSpaceInBytes()
        if usedSpaceInBytes > 0 {
            return ByteCountFormatter.string(fromByteCount: usedSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
        return "The used disk space on this device is unknown"
    }
}

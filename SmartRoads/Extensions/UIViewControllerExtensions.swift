//
//  UIViewControllerExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 15.04.21.
//

import UIKit

extension UIViewController {
    func rotateToLandscapeLeft() {
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
    }
    
    func lockToPortraitMode() {
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")

    }
}

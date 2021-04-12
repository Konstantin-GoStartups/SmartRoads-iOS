//
//  UIViewExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 11.04.21.
//

import UIKit

extension UIView {
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

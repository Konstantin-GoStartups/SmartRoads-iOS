//
//  HashableExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 1.04.21.
//

import Foundation
import UIKit

extension Hashable {
    func share() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIApplication.topViewController?.present(activity, animated: true, completion: nil)
    }
}

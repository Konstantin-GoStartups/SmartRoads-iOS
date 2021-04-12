//
//  ControlEnums.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import Foundation

enum PreviewMode: Int {
  case original
  case depth
  case mask
  case filtered
}

enum FilterType: Int {
  case comic
  case greenScreen
  case blur
}

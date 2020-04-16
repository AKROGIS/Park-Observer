//
//  Environment.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct DarkMapKey: EnvironmentKey {
  static var defaultValue: Bool = true
}

extension EnvironmentValues {
  var darkMap: Bool {
    get { self[DarkMapKey.self] }
    set { self[DarkMapKey.self] = newValue }
  }
}

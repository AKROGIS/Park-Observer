//
//  Environment.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This file declares new keys and a corresponding data type and default value for data that
/// might be added to the SwiftUI environment and available as readonly settings for child views
/// This file declares default values/state but does not mutate, manage, or respond to the state.

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

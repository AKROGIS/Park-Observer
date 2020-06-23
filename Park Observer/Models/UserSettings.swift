//
//  UserSettings.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

class UserSettings: ObservableObject {

  /// MapControls can be light (for dark colored maps), or dark (for light maps)
  @Published var darkMapControls = false

  func restoreState() {
    darkMapControls = Defaults.darkMapControls.readBool()
  }

  func saveState() {
    Defaults.darkMapControls.write(darkMapControls)
  }

}

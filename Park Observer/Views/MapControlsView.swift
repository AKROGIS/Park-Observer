//
//  MapControlsView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/9/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MapControlsView: View {
  @EnvironmentObject var locationButtonController: LocationButtonController
  @EnvironmentObject var viewPointController: ViewPointController
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    return HStack {
      ScalebarView()
        .frame(width: 200.0, height: 36)
      Spacer()
      if viewPointController.rotation != 0 {
        Button(
          action: {
            //withAnimation(Animation.easeOut(duration: 0.5).delay(0.5)) {
            self.viewPointController.rotation = 0.0
            //}
        }) {
          CompassView(rotation: -1 * viewPointController.rotation, darkMode: userSettings.darkMapControls)
        }
        .mapButton(darkMode: userSettings.darkMapControls, size: userSettings.controlSize)
        //.transition(AnyTransition.scale.combined(with:.opacity))
      }
      LocationButtonView(controller: locationButtonController)
    }
  }

}

struct MapControlsView_Previews: PreviewProvider {
  static var previews: some View {
    MapControlsView()
  }
}

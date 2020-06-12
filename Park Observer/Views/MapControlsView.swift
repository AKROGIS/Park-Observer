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

  var body: some View {
    print("MapControlsView: rotation = \(viewPointController.rotation)")
    return HStack {
      ScalebarView()
        .frame(width: 200.0, height: 36)
      Spacer()
      CompassView(rotation: $viewPointController.rotation)
      LocationButtonView(controller: locationButtonController)
    }
  }

}

struct MapDashboardView_Previews: PreviewProvider {
  static var previews: some View {
    MapControlsView()
  }
}

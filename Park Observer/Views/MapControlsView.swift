//
//  MapControlsView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/9/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MapControlsView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    print("MapControlsView: rotation = \(surveyController.viewPointController.rotation)")
    return HStack {
      ScalebarView()
        .frame(width: 200.0, height: 36)
      Spacer()
      if surveyController.viewPointController.rotation != 0.0 {
        CompassView(
          rotation: surveyController.viewPointController.rotation,
          action: {
            self.surveyController.mapView.setViewpointRotation(0, completion: nil)
          }).transition(.opacity)
      }
      LocationButtonView(controller: surveyController.locationButtonController)
    }
  }

}

struct MapDashboardView_Previews: PreviewProvider {
  static var previews: some View {
    MapControlsView()
  }
}

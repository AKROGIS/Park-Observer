//
//  ContentView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var controller: MapViewController = MapViewController()

  var body: some View {
    ZStack(alignment: .topTrailing) {
      MapView(mapViewController: controller).edgesIgnoringSafeArea(.all)
      HStack() {
        ScalebarView(mapViewController: controller)
          .frame(width: 200.0, height: 36)
        // Important!  CompassView must be instantiated after MapView
        //   Compass initiation requires a non-nil AGSMapView, which is created in MapView
        Spacer()
        CompassView(mapViewController: controller)
          .frame(width: 30.0, height: 30)
        if controller.locationDisplayOn {
          AutoPanModeButtonView(autoPanMode: $controller.autoPanMode)
            .padding().background(Color.white)
        }
      }.padding([.leading,.trailing], 20.0)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

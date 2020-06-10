//
//  ContentView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    let mapViewController = MapViewController()
    mapViewController.mapView = surveyController.mapView
    return ZStack(alignment: .topTrailing) {
      MapView().edgesIgnoringSafeArea(.all)
      MapControlsView().padding([.leading, .trailing], 20.0).environmentObject(mapViewController)
    }.environment(\.darkMap, true)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

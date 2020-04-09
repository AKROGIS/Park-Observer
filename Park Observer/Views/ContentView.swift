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
      MapControlsView(mapViewController: controller).padding([.leading,.trailing], 20.0)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

//
//  MapListView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct OnlineMapListView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    List {
      ForEach(Array(SurveyController.esriBasemaps.keys.sorted()), id: \.self) { mapName in
        //TODO: add thumbnail, date and author
        Text(mapName)
          .onTapGesture {
            self.surveyController.loadMap(name: mapName)
            self.surveyController.slideOutMenuVisible.toggle()
        }
      }
    }
  }

}

struct MapListView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineMapListView()
    }
}

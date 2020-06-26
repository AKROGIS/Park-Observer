//
//  OnlineMapListView.swift
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
      ForEach(Array(SurveyController.esriBasemaps.keys.sorted()), id: \.self) { name in
        //TODO: add thumbnail, date and author
        HStack {
          if self.surveyController.mapName == name {
            Image(systemName: "star.fill").foregroundColor(.yellow)
          }
          Text(name)
            .font(self.surveyController.mapName == name ? .headline : .body)
            .onTapGesture {
              self.surveyController.loadMap(name: name)
              //self.surveyController.slideOutMenuVisible.toggle()
            }
        }
      }
    }
  }

}

struct OnlineMapListView_Previews: PreviewProvider {
  static var previews: some View {
    OnlineMapListView()
  }
}

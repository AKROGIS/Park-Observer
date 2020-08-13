//
//  MapItemView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MapItemView: View {
  var name: String

  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    let info = MapInfo(from: name)
    return HStack {
      if surveyController.mapName == name {
        Image(systemName: "star.fill").foregroundColor(.yellow)
      }
      VStack(alignment: .leading) {
        Text(info.title).font(surveyController.mapName == name ? .headline : .body)
        Text("Source: \(info.author)\(info.date == nil ? "" : " dated \(info.date!.shortDate)")")
          .font(.caption).foregroundColor(.secondary)
      }
    }
    .onTapGesture {
      self.surveyController.loadMap(name: self.name)
    }
  }

}

struct MapItemView_Previews: PreviewProvider {
  static var previews: some View {
    MapItemView(name: "map1")
  }
}

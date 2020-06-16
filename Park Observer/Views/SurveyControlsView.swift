//
//  SurveyControlsView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct SurveyControlsView: View {
  @EnvironmentObject var surveyController: SurveyController
  @Environment(\.darkMap) var darkMap

  var body: some View {
    HStack {
      Button(action: {}) {
        Image(systemName: "play").font(.headline)
      }
      .mapButton(darkMode: !darkMap)
      Button(action: {}) {
        Image(systemName: "play").font(.headline)
      }
      .mapButton(darkMode: !darkMap)
      Button(action: {}) {
        Image(systemName: "cloud.sun.rain").font(.headline)
      }
      .mapButton(darkMode: !darkMap)
      Button(action: {}) {
        Image(systemName: "mappin").font(.headline)
      }
      .mapButton(darkMode: !darkMap)
    }
  }

}

struct SurveyControlsView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyControlsView()
  }
}

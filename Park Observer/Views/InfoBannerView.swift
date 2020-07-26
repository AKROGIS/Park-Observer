//
//  InfoBannerView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct InfoBannerView: View {

  @EnvironmentObject var surveyController: SurveyController
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    HStack {
      Text(surveyController.infoBannerText)
        .padding(.vertical, 5)
        .padding(.leading)
        .font(.headline)
        .foregroundColor(userSettings.darkMapControls ? .black : .white)
        .shadow(color: userSettings.darkMapControls ? .white : .black, radius: 5.0)
      Spacer()
      Image(systemName: "xmark.circle.fill")
        .foregroundColor(userSettings.darkMapControls ? .black : .white)
        .padding(.trailing)
    }.overlay(
      // https://material.io/design/color/the-color-system.html#tools-for-picking-colors
      // Deep Purple 50 - A100 #B388FF
      Color(red: 179.0 / 255.0, green: 136.0 / 255.0, blue: 255.0 / 255.0)
        .opacity(0.3).onTapGesture {
          withAnimation { self.surveyController.isShowingInfoBanner = false }
        })
  }

}
struct InfoBannerView_Previews: PreviewProvider {
  static var previews: some View {
    InfoBannerView()
  }
}

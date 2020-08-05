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
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ZStack(alignment: .topTrailing) {
        MapView().edgesIgnoringSafeArea(.all)
        VStack {
          if surveyController.message != nil {
            MessageView(message: surveyController.message!)
          }
          if surveyController.isShowingTotalizer {
            TotalizerView().environmentObject(surveyController.totalizer)
          }
          if surveyController.isShowingInfoBanner {
            InfoBannerView()
          }
          if userSettings.surveyControlsOnBottom {
            MapControlsView().padding(20.0)
              .environmentObject(surveyController.viewPointController)
              .environmentObject(surveyController.locationButtonController)
          } else {
            SurveyControlsView().padding(20.0)
          }
        }
      }
      if userSettings.surveyControlsOnBottom {
        SurveyControlsView().padding(20.0)
      } else {
        MapControlsView().padding(20.0)
          .environmentObject(surveyController.viewPointController)
          .environmentObject(surveyController.locationButtonController)
      }
      SlideOutView()
    }.environmentObject(surveyController.userSettings)
      .alert(isPresented: $surveyController.showingAlert) { surveyController.alert! }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

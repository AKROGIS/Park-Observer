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
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    HStack(alignment: .bottom) {
      HStack {
        Button(action: {
          self.surveyController.slideOutMenuVisible.toggle()
        }) {
          Image(systemName: "slider.horizontal.3").font(.title)
        }
        .mapButton(darkMode: userSettings.darkMapControls)

        Spacer()

        Button(action: {
          self.surveyController.trackLogging.toggle()
        }) {
          Image(systemName: surveyController.trackLogging ? "stop.fill" : "play.fill").font(
            .headline)
        }
        .mapButton(darkMode: userSettings.darkMapControls)

        Button(action: {
          self.surveyController.observing.toggle()
        }) {
          Image(systemName: surveyController.observing ? "stop.fill" : "play.fill").font(.headline)
        }
        .disabled(!self.surveyController.trackLogging)
        .mapButton(darkMode: userSettings.darkMapControls)

        Button(action: {
          self.surveyController.addMissionPropertyAtGps(showEditor: false)
        }) {
          Image(systemName: "cloud.sun.rain").font(.headline)
        }
        .mapButton(darkMode: userSettings.darkMapControls)
      }
      VStack {
        ForEach(self.surveyController.featuresLocatableWithoutTouch, id: \.name) { feature in
          Button(action: {
            self.surveyController.addObservationAtGps(feature: feature)
          }) {
            ZStack(alignment: .bottomTrailing) {
              Image(systemName: "plus").font(.largeTitle)
              Text("\(String(feature.name.prefix(1)))")
                .font(.caption).bold()
                //TODO: Make sure this offset works in all cases + dynamic font sizes
                //  maybe best to fix the font size for both "plus" and feature code
                .offset(x: -1, y: 4.0)
            }
          }
          .mapButton(darkMode: self.userSettings.darkMapControls)
        }
      }
    }
    .actionSheet(isPresented: $surveyController.showMapTouchSelectionSheet) {
      ActionSheet(title: Text("Create new observation"), message: nil, buttons: sheetButtons())
    }
  }

  func sheetButtons() -> [ActionSheet.Button] {
    var buttons = [ActionSheet.Button]()
    for observation in surveyController.observationsLocatableWithTouch {
      let button = ActionSheet.Button.default(Text(observation.name)) {
        self.surveyController.viewDidSelectObservationClass(observation)
      }
      buttons.append(button)
    }
    let cancel = ActionSheet.Button.cancel(
      Text("Cancel"),
      action: { self.surveyController.viewDidSelectObservationClass(nil) }
    )
    buttons.append(cancel)
    return buttons
  }

}

struct SurveyControlsView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyControlsView()
  }
}

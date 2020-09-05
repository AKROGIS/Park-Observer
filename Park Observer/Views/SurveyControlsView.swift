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
    HStack(alignment: userSettings.surveyControlsOnBottom ? .bottom : .top) {
      HStack {
        Button(action: {
          self.surveyController.slideOutMenuVisible.toggle()
        }) {
          Image(systemName: "slider.horizontal.3").font(.title)
        }
        .mapButton(darkMode: userSettings.darkMapControls, size: userSettings.mapControlsSize)

        Spacer()

        if surveyController.showingTrackLogButton {
          Button(action: {
            withAnimation {
              self.surveyController.trackLogging.toggle()
            }
          }) {
            Group {
              if self.surveyController.trackLogging {
                Image(systemName: "stop.fill").font(.headline).padding()
              } else {
                HStack {
                  Image(systemName: "play.fill").font(.headline).padding(.leading)
                  Text(surveyController.trackLogLabel).fontWeight(.bold).padding(.trailing)
                }
              }
            }
          }
          .wideMapButton(darkMode: userSettings.darkMapControls, size: userSettings.mapControlsSize)
        }

        if surveyController.showingObserveButton {
          Button(action: {
            withAnimation {
              self.surveyController.observing.toggle()
            }
          }) {
            Group {
              if self.surveyController.observing {
                Image(systemName: "stop.fill").font(.headline).padding()
              } else {
                HStack {
                  Image(systemName: "play.fill").font(.headline).padding(.leading)
                  Text(surveyController.transectLabel).fontWeight(.bold).padding(.trailing)
                }
              }
            }
          }
          .wideMapButton(darkMode: userSettings.darkMapControls, size: userSettings.mapControlsSize)
        }

        if surveyController.showingMissionPropertiesButton {
          Button(action: {
            self.surveyController.addMissionPropertyAtGps(showEditor: true)
          }) {
            Image(systemName: "cloud.sun.rain").font(.headline)
          }
          .mapButton(darkMode: userSettings.darkMapControls, size: userSettings.mapControlsSize)
        }

      }
      VStack {
        ForEach(self.surveyController.featuresLocatableWithoutTouch, id: \.name) { feature in
          Button(action: {
            self.surveyController.addObservationAtGps(feature: feature)
          }) {
            ZStack(alignment: .center) {
              Image(systemName: "plus").font(.largeTitle)
              Text("\(String(feature.name.prefix(1)))")
                .font(.callout).bold()
                .alignmentGuide(HorizontalAlignment.center) { d in d[.leading] - d.width*0.25  }
                .alignmentGuide(VerticalAlignment.center) { d in d[.top] }
            }
          }
          .mapButton(
            darkMode: self.userSettings.darkMapControls, size: self.userSettings.mapControlsSize)
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

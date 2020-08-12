//
//  UserSettingsView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct UserSettingsView: View {
  @EnvironmentObject var surveyController: SurveyController
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {

    let controlSize = Binding<MapControlSize>(
      get: { return self.userSettings.mapControlsSize },
      set: { self.userSettings.mapControlsSize = $0 }
    )

    return Form {
      Section(header: Text("MAP CONTROLS")) {
        Toggle(isOn: $userSettings.darkMapControls) {
          Text("Dark mode")
        }
        Toggle(isOn: $userSettings.surveyControlsOnBottom) {
          VStack(alignment: .leading) {
            Text("Survey buttons on the bottom")
            Text("Map buttons/scale on the top").font(.caption).foregroundColor(.secondary)
          }
        }
        Picker("", selection: controlSize) {
          ForEach(MapControlSize.allCases) { size in
            Text(size.localizedString)
          }
        }.pickerStyle(SegmentedPickerStyle())
        Toggle(isOn: $userSettings.showAlarmClock) {
          Text("Alarm Clock")
        }
        if userSettings.showAlarmClock {
          DurationPicker(duration: $userSettings.alarmInterval)
        }
      }

      Section(header: Text("TRACK LOGS")) {
        Toggle(isOn: $surveyController.enableBackgroundTrackLogging) {
          VStack(alignment: .leading) {
            Text("Track log when not active")
            Text("Background track logging").font(.caption).foregroundColor(.secondary)
            if surveyController.enableBackgroundTrackLogging {
              Text("Warning: App will consume extra power when not active").foregroundColor(.red)
                .font(.subheadline)
            }
          }
        }
      }

      Section(header: Text("ATTRIBUTE EDITOR")) {
        Toggle(isOn: $userSettings.attributeButtonsOnTop) {
          VStack(alignment: .leading) {
            Text("Buttons on Top")
            Text("Edit/Cancel/Save/...").font(.caption).foregroundColor(.secondary)
          }
        }
      }

      Section(header: Text("BANNERS")) {
        if surveyController.hasInfoBannerDefinition {
          Toggle(isOn: $userSettings.showInfoBanner.animation()) {
            Text("Show Informational Banner")
          }
        }
        if surveyController.totalizerDefinition != nil {
          Toggle(isOn: $userSettings.showTotalizer.animation()) {
            Text("Show Totalizer")
          }
        }
      }

      Section(header: Text("GPS SETTINGS")) {
        Slider(
          value: $userSettings.gpsAccuracy, in: 5.0...200.0, minimumValueLabel: Text("5m"),
          maximumValueLabel: Text("200m")
        ) {
          Text("Accuracy")
        }
        Text("Frequency - time")
        Text("Frequency - distance")
      }
    }
  }

}

struct UserSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    UserSettingsView()
  }
}

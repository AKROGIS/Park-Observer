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

    let hasGpsAccuracyFilter = Binding<Bool>(
      get: { return self.userSettings.gpsAccuracyFilter > 0.0 },
      set: { self.userSettings.gpsAccuracyFilter = $0 ? 5.0 : 0.0 }
    )

    let hasGpsDistanceFilter = Binding<Bool>(
      get: { return self.userSettings.gpsDistanceFilter > 0.0 },
      set: { self.userSettings.gpsDistanceFilter = $0 ? 1.0 : 0.0 }
    )

    let hasGpsDurationFilter = Binding<Bool>(
      get: { return self.userSettings.gpsDurationFilter > 0.0 },
      set: { self.userSettings.gpsDurationFilter = $0 ? 1.0 : 0.0 }
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
        Toggle(isOn: $userSettings.showLocationInAttributeForm) {
          VStack(alignment: .leading) {
            Text("Show Location")
            Text("In the attribute editing form").font(.caption).foregroundColor(.secondary)
          }
        }
      }

      Section(header: Text("BANNERS")) {
        if surveyController.hasInfoBannerDefinition {
          Toggle(isOn: $userSettings.showInfoBanner.animation()) {
            Text("Show Informational Banner")
          }
        }
        if surveyController.totalizer != nil {
          Toggle(isOn: $userSettings.showTotalizer.animation()) {
            Text("Show Totalizer")
          }
        }
      }

      Section(header: Text("GPS SETTINGS")) {
        VStack {
          Toggle(isOn: hasGpsAccuracyFilter) {
            VStack(alignment: .leading) {
              Text("Use accuracy filter")
              Text("Set an accuracy standard for GPS points").font(.caption).foregroundColor(
                .secondary)
            }
          }
          if hasGpsAccuracyFilter.wrappedValue {
            HStack {
              Slider(value: $userSettings.gpsAccuracyFilter, in: 5.0...200.0)
              Text("±\(Int(userSettings.gpsAccuracyFilter)) meters")
            }
          }
        }
        VStack {
          Toggle(isOn: hasGpsDistanceFilter) {
            VStack(alignment: .leading) {
              Text("Use distance filter")
              Text("Set a minimum distance between tracklog points").font(.caption).foregroundColor(
                .secondary)
            }
          }
          if hasGpsDistanceFilter.wrappedValue {
            HStack {
              Slider(value: $userSettings.gpsDistanceFilter, in: 1.0...500.0)
              Text("\(Int(userSettings.gpsDistanceFilter)) meters")
            }
          }
        }
        VStack {
          Toggle(isOn: hasGpsDurationFilter) {
            VStack(alignment: .leading) {
              Text("Use duration filter")
              Text("Set a minimum time span between tracklog points").font(.caption)
                .foregroundColor(.secondary)
            }
          }.disabled(surveyController.isGpsIntervalDefinedByProtocol)
          if surveyController.isGpsIntervalDefinedByProtocol {
            Text("Locked by the survey configuration").font(.caption).foregroundColor(.red)
          }
          if hasGpsDurationFilter.wrappedValue {
            HStack {
              Slider(value: $userSettings.gpsDurationFilter, in: 1.0...60.0)
              Text("\(Int(userSettings.gpsDurationFilter)) seconds")
            }
          }
        }
      }
    }
  }

}

struct UserSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    UserSettingsView()
  }
}

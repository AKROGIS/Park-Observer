//
//  AlarmView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/5/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct AlarmView: View {

  @EnvironmentObject var userSettings: UserSettings

  @State private var alarmRunning = false
  @State private var showingSheet = false
  let ctrl = AlarmControl()

  var body: some View {
    Button(action: {
      self.showingSheet = true
    }) {
      Image(systemName: alarmRunning ? "alarm.fill" : "alarm")
        .font(Font.body.weight(.bold))
    }
    .actionSheet(isPresented: self.$showingSheet) {
      if self.alarmRunning {
        return ActionSheet(
          title: Text("Stop Alarm?"),
          message: nil,
          buttons: [
            .destructive(Text("Stop"), action: cancelAlarm),
            .cancel(Text("No"), action: {}),
          ]
        )
      } else {
        return ActionSheet(
          title: Text("Start Alarm?"),
          message: nil,
          buttons: [
            .default(Text("Start"), action: submitAlarm),
            .cancel(Text("No"), action: {}),
          ]
        )
      }
    }
  }

  //      .alert(isPresented: self.$showingSheet) {
  //        if self.alarmRunning {
  //          return Alert(
  //            title: Text("Stop Alarm?"),
  //            message: nil,
  //            primaryButton: .destructive(Text("Stop"), action: cancelAlarm),
  //            secondaryButton: .cancel(Text("No"), action: {})
  //          )
  //        } else {
  //          return Alert(
  //            title: Text("Start Alarm?"),
  //            message: nil,
  //            primaryButton: .default(Text("Start"), action: submitAlarm),
  //            secondaryButton: .cancel(Text("No"), action: {})
  //          )
  //        }
  //    }
  //  }

  private func cancelAlarm() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    alarmRunning = false
  }

  private func submitAlarm() {
    UNUserNotificationCenter.current().delegate = ctrl

    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = "Alarm!"
    content.body = "Time is up."
    content.sound = UNNotificationSound.default

    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: userSettings.alarmInterval, repeats: true)

    let request = UNNotificationRequest(
      identifier: UUID().uuidString, content: content, trigger: trigger)
    center.add(request)

    alarmRunning = true
  }

}

struct AlarmView_Previews: PreviewProvider {
  static var previews: some View {
    AlarmView()
  }
}

class AlarmControl: NSObject, UNUserNotificationCenterDelegate {

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler(.alert)
  }

}

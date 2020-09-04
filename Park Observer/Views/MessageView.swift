//
//  MessageView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/18/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MessageView: View {

  let message: Message

  @EnvironmentObject var surveyController: SurveyController
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    HStack {
      Text(message.text)
        .padding(.vertical, 5)
        .padding(.leading)
        .font(.headline)
        .foregroundColor(userSettings.darkMapControls ? .black : .white)
        .shadow(color: userSettings.darkMapControls ? .white : .black, radius: 5.0)
      Spacer()
      Image(systemName: "xmark.circle.fill")
        .foregroundColor(userSettings.darkMapControls ? .black : .white)
        .padding(.trailing)
    }.background(
      message.color.opacity(0.7)
    )
      .onTapGesture {
        withAnimation { self.surveyController.messages.remove(self.message.id) }
    }
  }

}

struct Message: Identifiable {

  enum Kind {
    case error
    case warning
    case info
  }

  let id = UUID()
  let kind: Kind
  let text: String

  var color: some View {
    switch self.kind {
    case .error:
      return Color(red: 192.0 / 255.0, green: 57.0 / 255.0, blue: 43.0 / 255.0)
    case .warning:
      return Color(red: 244.0 / 255.0, green: 208.0 / 255.0, blue: 63.0 / 255.0)
    case .info:
      return Color(red: 30.0 / 255.0, green: 132.0 / 255.0, blue: 73.0 / 255.0)
    }
  }

}

extension Message {
  static func error(_ text: String) -> Message {
    return Message(kind: .error, text: text)
  }

  static func info(_ text: String) -> Message {
    return Message(kind: .info, text: text)
  }

  static func warning(_ text: String) -> Message {
    return Message(kind: .warning, text: text)
  }
}

struct MessageView_Previews: PreviewProvider {
  static var previews: some View {
    MessageView(message: Message(kind: .error, text: "No GPS Signal"))
  }
}

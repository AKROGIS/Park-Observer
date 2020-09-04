//
//  MessagesView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 9/4/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MessagesView: View {

  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    VStack {
      ForEach(surveyController.messages) { message in
        MessageView(message: message)
      }
    }
  }

}

typealias Messages = [Message]

extension Messages {
  mutating func remove(_ id: UUID) {
    if let index = self.firstIndex(where: { $0.id == id }) {
      self.remove(at: index)
    }
  }
}

struct MessagesView_Previews: PreviewProvider {
  static var previews: some View {
    MessagesView()
  }
}

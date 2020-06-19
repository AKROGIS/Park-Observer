//
//  SlideOutView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct SlideOutView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    ZStack {
      if self.surveyController.slideOutMenuVisible {
        Color(.gray).opacity(0.3)
          .onTapGesture {
            withAnimation {
              self.surveyController.slideOutMenuVisible.toggle()
            }
          }
      }
      //TODO: Add drag gesture to change width, and swipe to close

      HStack {
        //TODO: select one of the views conditionally Show conditionally with Attribute Editing View
        // AttributeEditingView
        // ????View
        MainMenuView()
          .frame(width: surveyController.slideOutMenuWidth)
          //TODO: set height to screen less keyboard height if keyboard is showing
          .background(Color.white)
          //TODO: refresh the visible view
          //hiding the slideout like this is nice because it restores to the same
          //place in the navigation heirarchy where we left off, but views the file
          //list do not refresh
          .offset(
            x: surveyController.slideOutMenuVisible ? 0 : -1 * surveyController.slideOutMenuWidth
          )
          //TODO: offset is not enough in landscape mode on iPhone 11 (with safe area)
          //TODO:  set y offset if keyboard is showing
          .animation(.default)
        Spacer()
      }
    }
  }
}

struct SlideOutView_Previews: PreviewProvider {
  static var previews: some View {
    SlideOutView()
  }
}

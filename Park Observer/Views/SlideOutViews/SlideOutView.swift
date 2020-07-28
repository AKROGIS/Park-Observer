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
  @State private var width: CGFloat = 0.0
  @State private var minWidth: CGFloat = 250

  var body: some View {
    ZStack {
      if self.surveyController.slideOutMenuVisible {
        Color(.gray).opacity(0.3)
          .onTapGesture {
            withAnimation {
              self.surveyController.slideOutMenuWidth = self.width
              self.surveyController.slideOutMenuVisible.toggle()
            }
          }
      }
      HStack {
        HStack(spacing: 0) {
          if self.surveyController.showingObservationEditor {
            NavigationView {
              ObservationView(item: surveyController.selectedItem ?? EditableObservation() )
            }
            .navigationViewStyle(StackNavigationViewStyle())
          } else if self.surveyController.showingObservationSelector {
            ObservationSelectorView()
          } else {
            MainMenuView()
          }
          ZStack {
            Color(.systemBackground).frame(width: 8).edgesIgnoringSafeArea(.all)
            RoundedRectangle(cornerRadius: 2.5).frame(width: 5, height: 100.0)
          }
            .gesture(
              DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged {
                  self.width = max(self.minWidth, $0.location.x)
                })
        }
          .frame(width: width)
          .offset(x: self.surveyController.slideOutMenuVisible ? 0 : -1 * width)
          .animation(.default)
        Spacer()
      }
        .onAppear {
          self.width = self.surveyController.slideOutMenuWidth
        }
    }
      .keyboardAdaptive()
  }
}

struct SlideOutView_Previews: PreviewProvider {
  static var previews: some View {
    SlideOutView()
  }
}

//TODO: conditionally replace MainMenuView with on of the following
//  AttributeEditingView
//  OtherView??
//TODO: limit to maxWidth as % of screenwidth
//TODO: on device rotation, recalc maxwidth and adjust width if necessary
//TODO: Add and swipe to close (but do not adjust width)
//TODO: Add close button on SlideOutView
//TODO: Deal with safe area; add to offset
//TODO: refresh the visible view
//  hiding the slideout like this is nice because it restores to the same
//  place in the navigation heirarchy where we left off, but views the file
//  list do not refresh

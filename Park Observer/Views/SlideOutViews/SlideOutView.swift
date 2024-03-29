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
        Color(.gray).opacity(0.5)
          .edgesIgnoringSafeArea(.all)
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
              ObservationView(
                presenter: surveyController.selectedObservation ?? ObservationPresenter())
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
        .animation(.default, value: self.surveyController.slideOutMenuVisible)
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

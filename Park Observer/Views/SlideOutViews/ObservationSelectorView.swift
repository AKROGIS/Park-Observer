//
//  ObservationSelectorView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/14/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ObservationSelectorView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    NavigationView {
      Form {
        List {
          ForEach(surveyController.selectedItems ?? [], id: \.timestamp) { item in
            NavigationLink(destination: FormView(form: self.surveyController.observationForm(for: item.graphic))) {
              VStack(alignment: .leading) {
                Text(item.description)
                Text(item.timestamp.shortDateMediumTime)
                  .font(.footnote).foregroundColor(.secondary)
              }
            }
          }
        }
      }
      .navigationBarTitle("Observations")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

}

struct ObservationSelectorView_Previews: PreviewProvider {
  static var previews: some View {
    ObservationSelectorView()
  }
}

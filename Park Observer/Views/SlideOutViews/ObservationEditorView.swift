//
//  ObservationEditorView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ObservationEditorView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    NavigationView {
      FormView(form: surveyController.observationForm)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

}

struct ObservationEditorView_Previews: PreviewProvider {
  static var previews: some View {
    ObservationEditorView()
  }
}

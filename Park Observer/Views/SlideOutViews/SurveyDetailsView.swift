//
//  SurveyDetailsView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct SurveyDetailsView: View {
  let name: String

  var body: some View {
    Text("Survey Details for: \(name)")
  }
}

struct SurveyDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyDetailsView(name: "survey1")
  }
}

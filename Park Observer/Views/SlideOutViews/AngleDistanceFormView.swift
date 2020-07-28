//
//  AngleDistanceFormView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct AngleDistanceFormView: View {
  let form: AngleDistanceFormDefinition

  var body: some View {
    // Expects to be embeded in a Form
    Section(
      header: OptionalTextView(form.header),
      footer: OptionalTextView(form.footer)
    ) {
      HStack {
        Text("Angle:")
        DoubleEditView(
          n: form.angle, placeholder: "", formatter: form.angleFormatter, stringFormat: "%.0f"
        )
      }
      HStack {
        Text("Distance:")
        DoubleEditView(
          n: form.angle, placeholder: "0..1000", formatter: form.distanceFormatter,
          stringFormat: "%.0f"
        )
      }
    }
  }

}

// Not testable at this point because AngleDistanceFormDefinition
// requires a non-optional CoreData entity which is hard to come by
/*
struct AngleDistanceFormView_Previews: PreviewProvider {
  static var previews: some View {
    AngleDistanceFormView(form: AngleDistanceFormDefinition())
  }
}
 */

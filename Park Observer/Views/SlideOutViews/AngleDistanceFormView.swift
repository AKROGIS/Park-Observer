//
//  AngleDistanceFormView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/28/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

/// Displays two editable text boxes for angle/distance double values
///
/// Expects to be embeded in a Form view
/// The required form property defines the look and feel of the form.
struct AngleDistanceFormView: View {
  let form: AngleDistanceFormDefinition

  var body: some View {
    // Expects to be embeded in a Form
    Section(
      header: OptionalTextView(form.header),
      footer: OptionalTextView(form.footer)
    ) {
      VStack(alignment: .leading) {
        HStack {
          Text(form.anglePrefix)
          DoubleEditView(
            n: form.angle, placeholder: "", formatter: form.angleFormatter,
            stringFormat: form.angleFormat
          )
          OptionalTextView(form.angleSuffix)
        }
        OptionalTextView(form.angleCaption).font(.caption).foregroundColor(.secondary)
      }
      VStack(alignment: .leading) {
        HStack {
          Text(form.distancePrefix)
          DoubleEditView(
            n: form.distance, placeholder: "", formatter: form.distanceFormatter,
            stringFormat: form.distanceFormat
          )
          OptionalTextView(form.distanceSuffix)
        }
        OptionalTextView(form.distanceCaption).font(.caption).foregroundColor(.secondary)
      }
    }
    .textFieldStyle(RoundedBorderTextFieldStyle())
    .keyboardType(.numbersAndPunctuation)
    .disableAutocorrection(true)
  }

}

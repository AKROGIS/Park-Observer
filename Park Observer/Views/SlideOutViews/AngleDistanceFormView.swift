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
  let showValidation: Bool
  // Use a counter for the state because we want the view to re-render
  // whenever the text changes
  @State private var angleEditCount = 0
  @State private var distanceEditCount = 0

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
            stringFormat: form.angleFormat, onLoseFocus: { self.angleEditCount += 1 }
          )
          .border(angleInvalid ? Color.red : .clear)
          OptionalTextView(form.angleSuffix)
        }
        if showValidation || angleEditCount > 0 {
          OptionalTextView(form.angleError).foregroundColor(.red)
        }
        if angleEditCount >= 0 {
          OptionalTextView(form.angleWarning).font(.callout).foregroundColor(.orange)
        }
        OptionalTextView(form.angleCaption).font(.caption).foregroundColor(.secondary)
      }
      VStack(alignment: .leading) {
        HStack {
          Text(form.distancePrefix)
          DoubleEditView(
            n: form.distance, placeholder: "", formatter: form.distanceFormatter,
            stringFormat: form.distanceFormat, onLoseFocus: { self.distanceEditCount += 1 }
          )
          .border(distanceInvalid ? Color.red : .clear)
          OptionalTextView(form.distanceSuffix)
        }
        if showValidation || distanceEditCount > 0 {
          OptionalTextView(form.distanceError).foregroundColor(.red)
        }
        OptionalTextView(form.distanceCaption).font(.caption).foregroundColor(.secondary)
      }
    }
    .textFieldStyle(RoundedBorderTextFieldStyle())
    .keyboardType(.numbersAndPunctuation)
    .disableAutocorrection(true)
  }

  var angleInvalid: Bool {
    return (showValidation || angleEditCount > 0) && form.angleError != nil
  }

  var distanceInvalid: Bool {
    return (showValidation || distanceEditCount > 0) && form.distanceError != nil
  }

}

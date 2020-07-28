//
//  ObservationEditorView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ObservationEditorView: View {
  var item: EditableObservation
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //  Text(item.timestamp.shortDateMediumTime)
    //    .font(.caption).foregroundColor(.secondary)
    //    .padding(.leading)
    Form {
      FormView(form: self.surveyController.observationForm(for: item.graphic))
        .disabled(item.presentationMode == .review)
      //TODO: Format,options and actions depend on item properties
      // isNew, isEditing, isMovable, ...
      if item.presentationMode != .review {
        Section {
          HStack {
            Spacer()
            Button(action: {}) {
              HStack {
                Image(systemName: "trash")
                Text("Delete")
              }.foregroundColor(.red)
            }
            Spacer()
          }
          HStack {
            Spacer()
            Button(action: {}) {
              Text("Move")
            }
            Spacer()
          }
          HStack {
            Spacer()
            Button(action: {}) {
              Text("Cancel")
            }
            Spacer()
            Button(action: {}) {
              Text("Save")
            }
            Spacer()
          }
        }
      }
    }.navigationBarTitle(item.description)
  }

}

struct ObservationEditorView_Previews: PreviewProvider {
  static var previews: some View {
    ObservationEditorView(item: EditableObservation())
  }
}

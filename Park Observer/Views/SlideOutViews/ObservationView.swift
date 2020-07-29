//
//  ObservationView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ObservationView: View {
  @ObservedObject var presenter: ObservationPresenter
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    // TODO: find some pleasing way to show the time the observation was collected
    //  Text(presenter.timestamp.shortDateMediumTime)
    //    .font(.caption).foregroundColor(.secondary)
    //    .padding(.leading)
    Form {
      if presenter.hasAngleDistanceForm {
        AngleDistanceFormView(form: presenter.angleDistanceForm!)
          .disabled(!presenter.isEditing)
      }
      if presenter.hasAttributeForm {
        AttributeFormView(form: presenter.attributeForm!)
          .disabled(!presenter.isEditing)
      }
      if presenter.awaitingGps {
        HStack {
          Image(systemName: "exclamationmark.square.fill")
            .foregroundColor(.red)
            .font(.title)
          Text("Waiting for Gps point").foregroundColor(.red)
        }
      }
      if presenter.awaitingFeature {
        HStack {
          Image(systemName: "exclamationmark.square.fill")
            .foregroundColor(.red)
            .font(.title)
          Text("Waiting for feature selection").foregroundColor(.red)
        }
      }
      if !presenter.isEditing {
        if presenter.isEditable {
          Button(action: { self.presenter.isEditing = true }) {
            HStack {
              Image(systemName: "pencil")
              Text("Edit")
            }
          }
        }
      } else {
        //TODO: Support cancel-on-top
        if presenter.isDeletable {
          Button(action: { self.presenter.delete() }) {
            HStack {
              Image(systemName: "trash")
              Text("Delete")
            }.foregroundColor(.red)
          }
        }
        if presenter.isMoveableToGps {
          Button(action: { self.presenter.initiateMoveToGps() }) {
            Text("Move to GPS Location")
          }
        }
        if presenter.isMoveableToTouch {
          Button(action: { self.presenter.initiateMoveToTouch() }) {
            Text("Move to Map Touch")
          }
        }
        Button(action: { self.presenter.cancel() }) {
          Text("Cancel")
        }
        Button(action: { self.presenter.save() }) {
          Text("Save")
        }
      }
    }.navigationBarTitle(presenter.title)
  }

}

struct ObservationView_Previews: PreviewProvider {
  static var previews: some View {
    ObservationView(presenter: ObservationPresenter())
  }
}

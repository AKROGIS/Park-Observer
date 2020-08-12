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
  @Environment(\.presentationMode) var presentation
  @State private var showValidation = false

  var body: some View {
    // TODO: find some pleasing way to show the time the observation was collected
    //  Text(presenter.timestamp.shortDateMediumTime)
    //    .font(.caption).foregroundColor(.secondary)
    //    .padding(.leading)
    Form {
      if !presenter.errorMessage.isEmpty {
        HStack {
          Image(systemName: "exclamationmark.square.fill")
            .foregroundColor(.red)
            .font(.title)
          Text(presenter.errorMessage).foregroundColor(.red)
        }
      }
      if presenter.hasAngleDistanceForm {
        AngleDistanceFormView(form: presenter.angleDistanceForm!, showValidation: $showValidation)
          .disabled(!presenter.isEditing)
      }
      if presenter.hasAttributeForm {
        AttributeFormView(form: presenter.attributeForm!, showValidation: $showValidation)
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

        // Delete

        if presenter.isDeletable {
          Button(action: {
            self.presenter.delete()
            if self.presenter.closeAllowed {
              if self.surveyController.showingObservationSelector {
                self.presentation.wrappedValue.dismiss()
              } else {
                self.surveyController.slideOutMenuVisible = false
              }
            }
          }) {
            HStack {
              Image(systemName: "trash")
              Text("Delete")
            }.foregroundColor(.red)
          }
        }

        // Move To GPS

        if presenter.isMoveableToGps {
          Button(action: { self.presenter.initiateMoveToGps() }) {
            Text("Move to GPS Location")
          }
        }

        // Move To Touch

        if presenter.isMoveableToTouch {
          Button(action: {
            self.presenter.initiateMoveToTouch()
            if self.presenter.closeAllowed {
              // Go directly to MapView, do NOT go back to selector, do not collect $200
              self.surveyController.slideOutMenuVisible = false
            }
          }) {
            Text("Move to Map Touch")
          }
        }

        // Cancel

        Button(action: {
          self.presenter.cancel()
          if self.surveyController.showingObservationSelector {
            self.presenter.reset()
            let kind = self.presenter.observationClass
            self.presenter.isEditing = self.surveyController.isEditingEnabled(for: kind)
            self.presentation.wrappedValue.dismiss()
          } else {
            self.surveyController.slideOutMenuVisible = false
          }
        }) {
          Text("Cancel")
        }

        // Save

        Button(action: {
          self.showValidation = true
          self.presenter.save()
          if self.presenter.closeAllowed {
            if self.surveyController.showingObservationSelector {
              let kind = self.presenter.observationClass
              self.presenter.isEditing = self.surveyController.isEditingEnabled(for: kind)
              self.presentation.wrappedValue.dismiss()
            } else {
              self.surveyController.slideOutMenuVisible = false
            }
          }
        }) {
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

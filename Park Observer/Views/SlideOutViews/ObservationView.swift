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
  @EnvironmentObject var userSettings: UserSettings
  @Environment(\.presentationMode) var presentation
  @State private var showValidation = false
  @State private var isAlertPresented = false

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
      if userSettings.attributeButtonsOnTop {
        attributeButtons
      }
      if presenter.hasAngleDistanceForm {
        AngleDistanceFormView(
          form: presenter.angleDistanceForm!,
          showValidation: showValidation || !presenter.closeAllowed
        )
        .disabled(!presenter.isEditing)
      }
      if presenter.hasAttributeForm {
        AttributeFormView(
          form: presenter.attributeForm!,
          showValidation: showValidation || !presenter.closeAllowed
        )
        .disabled(!presenter.isEditing)
      }
      if !userSettings.attributeButtonsOnTop {
        attributeButtons
      }
    }.navigationBarTitle(presenter.title)
      .alert(isPresented: $isAlertPresented) {
        Alert(
          title: Text("Delete Observation?"),
          message: Text("This cannot be undone."),
          primaryButton: .destructive(Text("Delete"), action: deleteAction),
          secondaryButton: .cancel())
      }
  }

  var attributeButtons: some View {
    Group {
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
        if presenter.isDeletable {
          Button(action: { self.isAlertPresented = true }) {
            HStack {
              Image(systemName: "trash")
              Text("Delete")
            }.foregroundColor(.red)
          }
        }
        if presenter.isMoveableToGps {
          Button(action: { self.presenter.initiateMoveToGps() }) { Text("Move to GPS Location") }
        }
        if presenter.isMoveableToTouch {
          Button(action: moveAction) { Text("Move to Map Touch") }
        }
        Button(action: cancelAction) { Text("Cancel") }
        Button(action: saveAction) { Text("Save") }
      }
    }
  }

  private func cancelAction() {
    self.presenter.cancel()
    if self.surveyController.showingObservationSelector {
      self.presenter.reset()
      let kind = self.presenter.observationClass
      self.presenter.isEditing = self.surveyController.isEditingEnabled(for: kind)
      self.presentation.wrappedValue.dismiss()
    } else {
      self.surveyController.slideOutMenuVisible = false
    }
  }

  private func deleteAction() {
    self.presenter.delete()
    if self.presenter.closeAllowed {
      if self.surveyController.showingObservationSelector {
        self.presentation.wrappedValue.dismiss()
      } else {
        self.surveyController.slideOutMenuVisible = false
      }
    }
  }

  private func moveAction() {
    self.presenter.initiateMoveToTouch()
    if self.presenter.closeAllowed {
      // Go directly to MapView, do NOT go back to selector, do not collect $200
      self.surveyController.slideOutMenuVisible = false
    }
  }

  private func saveAction() {
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
  }

}

struct ObservationView_Previews: PreviewProvider {
  static var previews: some View {
    ObservationView(presenter: ObservationPresenter())
  }
}

//
//  AttributeEditingView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import SwiftUI

struct AttributeEditingView: View {
  var body: some View {
    Text("Feature Editing")
  }
}

struct AttributeEditingView_Previews: PreviewProvider {
  static var previews: some View {
    AttributeEditingView()
  }
}

struct ObservationDetailsView: View {
  //TODO: Figure out a better way ro initialize the view with either
  //an intialization argument, or a published value on @EnvironmentObject
  var item1: EditableObservation? = nil
  @EnvironmentObject var surveyController: SurveyController
  @State private var item = EditableObservation()

  var body: some View {
    VStack(alignment: .leading) {
      Text(item.description).font(.title)
      Form {
        VStack(alignment: .leading) {
          Text("Observed")
          Text(item.timestamp.shortDateMediumTime)
            .font(.footnote).foregroundColor(.secondary)
        }
        ForEach(item.fields, id: \.name) { field in
          //TODO: Format based on field.type and self.item.dialog
          VStack(alignment: .leading) {
            Text(field.name)
            Text(self.value(field))
              .font(.footnote).foregroundColor(.secondary)
          }
        }
      }
      .onAppear {
        self.item = self.surveyController.editableObservation(for: self.item1?.graphic)
      }
      Spacer()
      Text("Footer")
        .font(.footnote).foregroundColor(.secondary)
        .padding()
    }
    .navigationBarTitle(item.description)
  }

  func value(_ field: Attribute) -> String {
    guard let object = item.object else {
      print("Managed object not found in ObservationDetailsView")
      return ""
    }
    let value = object.value(forKey: .attributePrefix + field.name)
    //TODO: Format based on field.type and self.item.dialog
    return "\(value ?? "<NULL>")"
  }

}

struct ObservationDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    AttributeEditingView()
  }
}

struct ObservationSelectorView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    NavigationView {
      List {
        ForEach(surveyController.selectedItems ?? [], id: \.timestamp) { item in
          NavigationLink(destination: ObservationDetailsView(item1: item)) {
            VStack(alignment: .leading) {
              Text(item.description)
              Text(item.timestamp.shortDateMediumTime)
                .font(.footnote).foregroundColor(.secondary)
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
    AttributeEditingView()
  }
}

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
  var graphic: AGSGraphic? = nil
  @EnvironmentObject var surveyController: SurveyController
  @State private var item = EditableObservation()

  var body: some View {
    VStack {
      Form {
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
        //TODO: These calls should be combined to return one struct
        self.item = self.surveyController.editableObservation(for: self.graphic)

      }
      Spacer()
      Text("Footer")
        .font(.footnote).foregroundColor(.secondary)
        .padding()
    }
    .navigationBarTitle(item.name)
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
        ForEach(surveyController.selectedGraphics ?? [], id: \.self) { graphic in
          NavigationLink(destination: ObservationDetailsView(graphic: graphic)) {
            Text(graphic.graphicsOverlay?.overlayID ?? "Unknown")
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

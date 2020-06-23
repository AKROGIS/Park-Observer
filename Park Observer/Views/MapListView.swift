//
//  MapListView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 6/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MapListView: View {
  @EnvironmentObject var surveyController: SurveyController
  @State private var errorMessage: String? = nil
  @State private var mapNames = [String]()

  var body: some View {
    List {
      ForEach(mapNames, id: \.self) { mapName in
        //TODO: add thumbnail, date and author
        Text(mapName)
          .onTapGesture {
            self.errorMessage = nil
            self.surveyController.loadMap(name: mapName)
            self.surveyController.slideOutMenuVisible.toggle()
        }
      }
      .onDelete(perform: delete)
      NavigationLink(destination: OnlineMapListView()) {
        Text("Online Maps")
      }
      if errorMessage != nil {
        HStack {
          Image(systemName: "exclamationmark.square.fill")
            .foregroundColor(.red)
            .font(.title)
          Text(errorMessage!).foregroundColor(.red)
        }
      }
    }
    .onAppear {
      self.mapNames = FileManager.default.mapNames.sorted()
    }
  }

  func delete(at offsets: IndexSet) {
    self.errorMessage = nil
    offsets.forEach { index in
      let name = mapNames[index]
      do {
        try FileManager.default.deleteMap(with: name)
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
    self.mapNames = FileManager.default.mapNames.sorted()
  }
}

struct OnlineMapListView: View {
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    List {
      ForEach(Array(SurveyController.esriBasemaps.keys.sorted()), id: \.self) { mapName in
        //TODO: add thumbnail, date and author
        Text(mapName)
          .onTapGesture {
            self.surveyController.loadMap(name: mapName)
            self.surveyController.slideOutMenuVisible.toggle()
        }
      }
    }
  }

}

struct MapListView_Previews: PreviewProvider {
    static var previews: some View {
        MapListView()
    }
}

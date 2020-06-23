//
//  MainMenuView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct MainMenuView: View {
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: MapListView()) {
          Text("Maps")
        }
        NavigationLink(destination: SurveyListView()) {
          Text("Surveys")
        }
        NavigationLink(destination: FileListView(fileType: .surveyProtocol)) {
          Text("Protocols")
        }
        NavigationLink(destination: FileListView(fileType: .archive)) {
          Text("Archives")
        }
        NavigationLink(destination: UserSettingsView()) {
          Text("Settings")
        }
      }
      .navigationBarTitle("Park Observer")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct MainMenuView_Previews: PreviewProvider {
  static var previews: some View {
    MainMenuView()
  }
}

//TODO: Move these Views to a separate file and implement

struct FileListView: View {
  var fileType: AppFileType

  var body: some View {
    //TODO: Implement
    Text("List of Files")
  }
}

struct SurveyListView: View {
  @EnvironmentObject var surveyController: SurveyController
  @State private var errorMessage: String? = nil
  @State private var surveyNames = [String]()

  var body: some View {
    List {
      ForEach(surveyNames, id: \.self) { surveyName in
        //TODO: replace file name with title from info; add icon, dates and status
        Text(surveyName)
          .onTapGesture {
            self.errorMessage = nil
            self.surveyController.loadSurvey(name: surveyName)
            self.surveyController.slideOutMenuVisible.toggle()
          }
      }
      .onDelete(perform: delete)
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
      self.surveyNames = FileManager.default.surveyNames.sorted()
    }
  }

  func delete(at offsets: IndexSet) {
    self.errorMessage = nil
    offsets.forEach { index in
      let name = surveyNames[index]
      do {
        try FileManager.default.deleteSurvey(with: name)
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
    self.surveyNames = FileManager.default.surveyNames.sorted()
  }
}

struct AttributeEditingView: View {

  var body: some View {
    Text("List of Gps Settings")
  }
}

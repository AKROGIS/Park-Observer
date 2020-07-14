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
      Form {
        List {
          NavigationLink(destination: FileListView(fileType: .survey)) {
            Text("Your Surveys")
          }
          NavigationLink(destination: FileListView(fileType: .map)) {
            Text("Background Maps")
          }
          NavigationLink(destination: FileListView(fileType: .surveyProtocol)) {
            VStack(alignment: .leading) {
              Text("Protocols")
              Text("Create a new survey").font(.caption).foregroundColor(.secondary)
            }
          }
          NavigationLink(destination: FileListView(fileType: .archive)) {
            VStack(alignment: .leading) {
              Text("Archives")
              Text("Exported and importable surveys").font(.caption).foregroundColor(.secondary)
            }
          }
          NavigationLink(destination: UserSettingsView()) {
            Text("Settings")
          }
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

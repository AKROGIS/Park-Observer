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
        NavigationLink(destination: FileListView(fileType: .map)) {
          Text("Maps")
        }
        NavigationLink(destination: FileListView(fileType: .survey)) {
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

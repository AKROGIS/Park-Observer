//
//  FileListView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct FileListView: View {
  var fileType: AppFileType
  @EnvironmentObject var surveyController: SurveyController
  @State private var errorMessage: String? = nil
  @State private var fileNames = [String]()
  @State private var title: String = ""

  var body: some View {
    VStack { //(alignment: .leading) {
      Form {
        ForEach(fileNames, id: \.self) { name in
          FileItemView(file: AppFile(type: self.fileType, name: name))
        }
        .onDelete(perform: delete)
        if fileType == .map {
          NavigationLink(destination: OnlineMapListView()) {
            Text("Online Maps")
          }
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
        self.errorMessage = nil
        self.fileNames = FileManager.default.names(type: self.fileType).sorted()
        switch self.fileType {
        case .map: self.title = "Select a Map"; break
        case .survey: self.title = "Select a Survey"; break
        case .archive: self.title = "Survey Archives"; break
        case .surveyProtocol: self.title = "Configuration Files"; break
        }
      }
      Spacer()
      Text((fileType == .surveyProtocol ? "Tap to create a new survey from the configuration. " : "") + "Swipe to the left to delete a file.")
      .font(.footnote).foregroundColor(.secondary)
      .padding()
    }
    .navigationBarTitle(title)
  }

  func delete(at offsets: IndexSet) {
    self.errorMessage = nil
    offsets.forEach { index in
      let name = fileNames[index]
      do {
        let file = AppFile(type: self.fileType, name: name)
        try FileManager.default.delete(file: file)
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
    self.fileNames = FileManager.default.names(type: fileType).sorted()
  }
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
      FileListView(fileType: .map)
    }
}

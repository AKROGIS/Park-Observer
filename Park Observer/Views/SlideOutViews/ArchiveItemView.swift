//
//  ArchiveItemView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ArchiveItemView: View {
  var name: String
  @State private var showingActionSheet = false
  @State private var infoMessage: String? = nil
  @State private var errorMessage: String? = nil
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Button(action: {
          self.infoMessage = nil
          self.errorMessage = nil
          self.importArchive()
        }) {
          HStack {
            Image(systemName: "tray.and.arrow.down")
            VStack(alignment: .leading) {
              Text(name)
              Text(creationDate(for: name)).font(.caption).foregroundColor(.secondary)
            }
          }
        }
        if errorMessage != nil {
          Text(errorMessage!).font(.caption).foregroundColor(.red)
        }
        if infoMessage != nil {
          Text(infoMessage!).font(.caption).foregroundColor(.green)
        }
      }
    }.actionSheet(isPresented: $showingActionSheet) {
      ActionSheet(
        title: Text("Survey exists"),
        message: Text(
          "This survey already exists. Do you want to replace it with the one in this archive?"),
        buttons: [
          ActionSheet.Button.destructive(
            Text("Replace"),
            action: {
              self.importArchiveReplace()
            }),
          ActionSheet.Button.default(
            Text("Keep Both"),
            action: {
              self.importArchiveKeepBoth()
            }),
          ActionSheet.Button.default(
            Text("Stop"),
            action: {}),
        ])
    }
  }

  private func creationDate(for name: String) -> String {
    let url = FileManager.default.archiveURL(with: name)
    if let date = FileManager.default.creationDate(url: url) {
      return "Created: \(date.mediumDate)"
    } else {
      return "Created: Unknown"
    }
  }

  private func importArchive() {
    do {
      let surveyName = try FileManager.default.importSurvey(from: name, conflict: .fail)
      infoMessage = "Added \(surveyName) to your surveys"
    } catch {
      if (error as NSError).code == NSFileWriteFileExistsError {
        showingActionSheet = true
      } else {
        errorMessage = error.localizedDescription
      }
    }
  }

  private func importArchiveKeepBoth() {
    do {
      let surveyName = try FileManager.default.importSurvey(from: name, conflict: .keepBoth)
      infoMessage = "Added \(surveyName) to your surveys"
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func importArchiveReplace() {
    do {
      let surveyName = try FileManager.default.importSurvey(from: name, conflict: .replace)
      infoMessage = "Added \(surveyName) to your surveys"
    } catch {
      errorMessage = error.localizedDescription
    }
  }

}

struct ArchiveItemView_Previews: PreviewProvider {
  static var previews: some View {
    ArchiveItemView(name: "archive1")
  }
}

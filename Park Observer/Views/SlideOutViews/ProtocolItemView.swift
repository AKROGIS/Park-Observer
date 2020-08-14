//
//  ProtocolItemView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ProtocolItemView: View {
  var name: String
  @State private var navigationTag: Int? = 0
  @State private var errorMessage: String? = nil
  @State private var infoMessage: String? = nil
  @State private var showingActionSheet = false
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    let url = FileManager.default.protocolURL(with: name)
    let info = try? SurveyProtocol(fromURL: url, skipValidation: true)

    return VStack(alignment: .leading) {
      NavigationLink(
        destination: ProtocolDetailsView(
          name: name, url: FileManager.default.protocolURL(with: name)
        ), tag: 1, selection: $navigationTag
      ) {
        EmptyView()
      }
      HStack {
        VStack(alignment: .leading) {
          if info == nil {
            Text(name)
          } else {
            Text(info!.name)
            Text(details(for: info!)).font(.caption).foregroundColor(.secondary)
          }
        }.onTapGesture {
          self.infoMessage = nil
          self.errorMessage = nil
          self.createSurvey()
        }
        Spacer()
        Button(action: { self.navigationTag = 1 }) {
          Image(systemName: "info.circle")
        }
      }
      if infoMessage != nil {
        Text(infoMessage!).font(.caption).foregroundColor(.green)
      }
      if errorMessage != nil {
        Text(errorMessage!).font(.caption).foregroundColor(.red)
      }
    }.actionSheet(isPresented: $showingActionSheet) {
      ActionSheet(
        title: Text("Survey exists"),
        message: Text("This survey already exists. Do you want to replace it with a new one?"),
        buttons: [
          ActionSheet.Button.destructive(
            Text("Replace"),
            action: {
              self.createSurveyReplace()
            }),
          ActionSheet.Button.default(
            Text("Keep Both"),
            action: {
              self.createSurveyKeepBoth()
            }),
          ActionSheet.Button.default(
            Text("Stop"),
            action: {}),
        ])
    }
  }

  private func details(for info: SurveyProtocol) -> String {
    let version = "\(info.majorVersion).\(info.minorVersion)"
    let date = info.date == nil ? "Unknown" : info.date!.mediumDate
    return "Version: \(version), Date: \(date)"
  }

  private func createSurvey() {
    do {
      let newName = try Survey.create(self.name, from: self.name, conflict: .fail)
      infoMessage = "Created new survey \(newName)"
    } catch {
      if (error as NSError).code == NSFileWriteFileExistsError {
        showingActionSheet = true
      } else {
        errorMessage = error.localizedDescription
      }
    }
  }

  private func createSurveyKeepBoth() {
    do {
      let newName = try Survey.create(self.name, from: self.name, conflict: .keepBoth)
      infoMessage = "Created new survey \(newName)"
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func createSurveyReplace() {
    do {
      let newName = try Survey.create(self.name, from: self.name, conflict: .replace)
      infoMessage = "Created new survey \(newName)"
    } catch {
      errorMessage = error.localizedDescription
    }
  }

}

struct ProtocolItemView_Previews: PreviewProvider {
  static var previews: some View {
    ProtocolItemView(name: "protocol1")
  }
}

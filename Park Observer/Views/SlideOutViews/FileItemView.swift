//
//  FileItemView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/25/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct FileItemView: View {
  var file: AppFile
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    // Use group to "genericize" the various views that may actually be used
    Group {
      // Use exaustive switch when available in next release of swiftUI
      if file.type == .survey {
        SurveyItemView(name: file.name)
      } else if file.type == .map {
        MapItemView(name: file.name)
      } else if file.type == .archive {
        ArchiveItemView(name: file.name)
      } else {
        ProtocolItemView(name: file.name)
      }
    }
  }
}

struct MapItemView: View {
  var name: String

  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    let info = MapInfo(from: name)
    return HStack {
      if surveyController.mapName == name {
        Image(systemName: "star.fill").foregroundColor(.yellow)
      }
      VStack(alignment: .leading) {
        Text(info.title).font(surveyController.mapName == name ? .headline : .body)
        Text("Source: \(info.author)\(info.date == nil ? "" : " dated \(info.date!.shortDate)")")
          .font(.caption).foregroundColor(.secondary)
      }
    }
    .onTapGesture {
      self.surveyController.loadMap(name: self.name)
    }
  }
}

struct SurveyItemView: View {
  var name: String
  @State private var showingActionSheet = false
  @State private var isExporting = false
  @State private var infoMessage: String? = nil
  @State private var errorMessage: String? = nil
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) Support other conflict resolution strategies
    //TODO: 2) Edit Name of survey
    //TODO: 3) navigate to additional info about the survey
    //TODO: 4) Use progressView when archiving
    let info = try? SurveyInfo(fromURL: FileManager.default.surveyInfoURL(with: name))

    return VStack(alignment: .leading) {
      HStack {
        VStack(alignment: .leading) {
          HStack {
            if surveyController.surveyName == name {
              Image(systemName: "star.fill").foregroundColor(.yellow)
            }
            Text(info?.title ?? name)
              .font(surveyController.surveyName == name ? .headline : .body)
          }
          Group {
            if info != nil {
              if info!.version > 1 {
                // Version 1 (Legacy Surveys) did not correctly update the status
                Text("Status: \(info!.state.localizedString)")
                  .fontWeight(info!.state == .modified ? .bold : .regular)
              }
            }
            if info?.creationDate == nil {
              Text("Created: Legacy survey - Unknown")
            } else {
              Text("Created: \(info!.creationDate!.shortDateMediumTime)")
            }
            if info?.modificationDate == nil {
              Text("Not Modifed")
            } else {
              Text("Modifed: \(info!.modificationDate!.shortDateMediumTime)")
            }
            if info?.exportDate == nil {
              Text("Not Exported")
            } else {
              Text("Exported: \(info!.exportDate!.shortDateMediumTime)")
            }
          }.font(.caption).foregroundColor(.secondary)
        }
        .onTapGesture {
          self.surveyController.loadSurvey(name: self.name)
        }
        Spacer()
        Button(action: {
          self.infoMessage = nil
          self.errorMessage = nil
          self.isExporting = true
          self.createArchive()
        }) {
          if self.isExporting {
            // In ios14 use ProgressView()
            ActivityIndicatorView(isAnimating: .constant(true), style: .medium)
          } else {
            Image(systemName: "tray.and.arrow.up")
          }
        }
        .buttonStyle(BorderlessButtonStyle())
        .disabled(
          self.isExporting || (surveyController.surveyName == name && surveyController.trackLogging)
        )
      }
      if errorMessage != nil {
        Text(errorMessage!).font(.caption).foregroundColor(.red)
      }
      if infoMessage != nil {
        Text(infoMessage!).font(.caption).foregroundColor(.green)
      }
    }.actionSheet(isPresented: $showingActionSheet) {
      ActionSheet(
        title: Text("Archive exists"),
        message: Text(
          "An archive for this survey already exists. Do you want to replace it with a new one?"),
        buttons: [
          ActionSheet.Button.destructive(
            Text("Replace"),
            action: {
              self.createArchiveReplace()
            }),
          ActionSheet.Button.default(
            Text("Keep Both"),
            action: {
              self.createArchiveKeepBoth()
            }),
          ActionSheet.Button.default(
            Text("Stop"),
            action: {
              self.isExporting = false
            }),
        ])
    }
  }

  private func createArchive() {
    Survey.export(self.name, conflict: .fail) { error in
      if let error = error {
        self.errorMessage = error.localizedDescription
        self.showingActionSheet = true
      } else {
        self.infoMessage = "Exported survey"
        self.isExporting = false
      }
    }
  }

  private func createArchiveKeepBoth() {
    Survey.export(self.name, conflict: .keepBoth) { error in
      if let error = error {
        self.errorMessage = error.localizedDescription
      } else {
        self.infoMessage = "Exported survey"
        self.errorMessage = nil
      }
      self.isExporting = false
    }
  }

  private func createArchiveReplace() {
    Survey.export(self.name, conflict: .replace) { error in
      if let error = error {
        self.errorMessage = error.localizedDescription
      } else {
        self.infoMessage = "Exported survey"
        self.errorMessage = nil
      }
      self.isExporting = false
    }
  }
}

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

  func creationDate(for name: String) -> String {
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
      errorMessage = error.localizedDescription
      showingActionSheet = true
    }
  }

  private func importArchiveKeepBoth() {
    do {
      let surveyName = try FileManager.default.importSurvey(from: name, conflict: .keepBoth)
      infoMessage = "Added \(surveyName) to your surveys"
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func importArchiveReplace() {
    do {
      let surveyName = try FileManager.default.importSurvey(from: name, conflict: .replace)
      infoMessage = "Added \(surveyName) to your surveys"
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

}

struct ProtocolItemView: View {
  var name: String
  @State private var errorMessage: String? = nil
  @State private var infoMessage: String? = nil
  @State private var showingActionSheet = false
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 3) navigate to additional info about the protocol
    let url = FileManager.default.protocolURL(with: name)
    let info = try? SurveyProtocol(fromURL: url, skipValidation: true)

    return VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        if info == nil {
          Text(name)
        } else {
          Text(info!.name)
          Text(details(for: info!)).font(.caption).foregroundColor(.secondary)
        }
      }
      .onTapGesture {
        self.infoMessage = nil
        self.errorMessage = nil
        self.createSurvey()
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

  func details(for info: SurveyProtocol) -> String {
    let version = "\(info.majorVersion).\(info.minorVersion)"
    let date = info.date == nil ? "Unknown" : info.date!.mediumDate
    return "Version: \(version), Date: \(date)"
  }

  private func createSurvey() {
    do {
      let newName = try Survey.create(self.name, from: self.name, conflict: .fail)
      infoMessage = "Created new survey \(newName)"
    } catch {
      errorMessage = error.localizedDescription
      showingActionSheet = true
    }
  }

  private func createSurveyKeepBoth() {
    do {
      let newName = try Survey.create(self.name, from: self.name, conflict: .keepBoth)
      infoMessage = "Created new survey \(newName)"
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func createSurveyReplace() {
    do {
      let newName = try Survey.create(self.name, from: self.name, conflict: .replace)
      infoMessage = "Created new survey \(newName)"
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

}

struct FileItemView_Previews: PreviewProvider {
  static var previews: some View {
    FileItemView(file: AppFile(type: .map, name: "My Map"))
  }
}

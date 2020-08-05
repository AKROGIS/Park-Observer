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
  @State private var isExporting = false
  @State private var infoMessage: String? = nil
  @State private var errorMessage: String? = nil
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) Support other conflict resolution strategies
    //TODO: 3) navigate to additional info about the survey
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
          Survey.export(self.name, conflict: .fail) { error in
            if let error = error {
              self.errorMessage = error.localizedDescription
            } else {
              self.infoMessage = "Exported survey"
            }
            self.isExporting = false
          }
        }) {
          if self.isExporting {
            // In Xcode 12 (beta) use ProgressView()
            // Until then, wrap UIActivityIndicatorView (https://stackoverflow.com/a/56496896)
            Image(systemName: "staroflife.fill")
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
    }
  }
}

struct ArchiveItemView: View {
  var name: String
  @State private var infoMessage: String? = nil
  @State private var errorMessage: String? = nil
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) Support other conflict resolution strategies
    //TODO: 2) add file date
    HStack {
      VStack(alignment: .leading) {
        Button(action: {
          self.infoMessage = nil
          self.errorMessage = nil
          do {
            _ = try FileManager.default.importSurvey(from: self.name, conflict: .fail)
            self.infoMessage = "Added to your surveys"
          } catch {
            self.errorMessage = error.localizedDescription
          }
        }) {
          HStack {
            Image(systemName: "tray.and.arrow.down")
            VStack(alignment: .leading) {
              Text(name)
              Text("Created: June 12, 2020").font(.caption).foregroundColor(.secondary)
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
    }
  }
}

struct ProtocolItemView: View {
  var name: String
  @State private var errorMessage: String? = nil
  @State private var infoMessage: String? = nil
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) Support other conflict resolution strategies
    //TODO: 2) Replace file name with title, version, date from SurveyProtocol
    //TODO: 3) navigate to additional info about the protocol
    VStack(alignment: .leading) {
      Text(name)
        .onTapGesture {
          self.infoMessage = nil
          self.errorMessage = nil
          do {
            let newName = try Survey.create(self.name, from: self.name, conflict: .fail)
            self.infoMessage = "Created new survey \(newName)"
          } catch {
            self.errorMessage = error.localizedDescription
          }
        }
      if infoMessage != nil {
        Text(infoMessage!).font(.caption).foregroundColor(.green)
      }
      if errorMessage != nil {
        Text(errorMessage!).font(.caption).foregroundColor(.red)
      }
    }
  }
}

struct FileItemView_Previews: PreviewProvider {
  static var previews: some View {
    FileItemView(file: AppFile(type: .map, name: "My Map"))
  }
}

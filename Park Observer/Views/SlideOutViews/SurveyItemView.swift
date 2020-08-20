//
//  SurveyItemView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct SurveyItemView: View {
  var name: String
  @State private var navigationTag: Int? = 0
  @State private var isEditingName = false
  @State private var editName = ""
  @State private var showingActionSheet = false
  @State private var isExporting = false
  @State private var info: SurveyInfo? = nil
  @State private var infoMessage: String? = nil
  @State private var errorMessage: String? = nil
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        VStack(alignment: .leading) {
          HStack {
            if surveyController.surveyName == name {
              Image(systemName: "star.fill").foregroundColor(.yellow)
            }
            if isEditingName {
              HStack {
                ZStack(alignment: .trailing) {
                  TextField(
                    "", text: $editName,
                    onEditingChanged: { gotFocus in
                      if !gotFocus {
                        print("Done Editing; new name: \(self.editName)")
                        self.updateTitle(self.editName)
                        self.isEditingName = false
                      }
                    },
                    onCommit: {
                      print("Done Editing; new name: \(self.editName)")
                      self.updateTitle(self.editName)
                      self.isEditingName = false

                    }
                  ).textFieldStyle(RoundedBorderTextFieldStyle())
                  Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    .padding(.trailing, 5)
                    .onTapGesture { self.editName = "" }
                }
                Button(action: {
                  self.editName = self.info?.title ?? self.name
                  self.isEditingName = false
                }) {
                  Image(systemName: "arrow.uturn.left.circle")
                }.buttonStyle(BorderlessButtonStyle())
              }
            } else {
              Text(info?.title ?? name)
                .font(surveyController.surveyName == name ? .headline : .body)
                .onTapGesture {
                  self.surveyController.loadSurvey(name: self.name)
                }
              Button(action: { self.isEditingName = true }) {
                Image(systemName: "pencil")
              }.buttonStyle(BorderlessButtonStyle())
            }
          }
          Group {
            if info != nil {
              if info!.version > 1 {
                // Version 1 (Legacy Surveys) did not correctly update the status
                Text("Status: \(info!.state.localizedString)")
                  .fontWeight(
                    (info!.state == .modified || info!.state == .corrupt) ? .bold : .regular
                  )
                  .foregroundColor(info!.state == .corrupt ? .red : .secondary)
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
            .onTapGesture {
              self.surveyController.loadSurvey(name: self.name)
            }
        }
        Spacer()
        VStack {
          Spacer()
          Button(action: { self.navigationTag = 1 }) {
            HStack {
              Image(systemName: "info.circle")
              // The NavLink does not show up in the simulator (desired), but it does show up
              // on a device (13.6), so this minimizes the impact
              NavigationLink(
                destination: SurveyDetailsView(name: name), tag: 1, selection: $navigationTag
              ) {
                EmptyView()
              }.frame(width: 0, height: 0, alignment: .center).foregroundColor(.clear)
            }
          }.buttonStyle(BorderlessButtonStyle())
          Spacer()
          Button(action: {
            self.infoMessage = nil
            self.errorMessage = nil
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
            self.isExporting
              || (surveyController.surveyName == name && surveyController.trackLogging)
          )
          Spacer()
        }
      }
      if errorMessage != nil {
        Text(errorMessage!).font(.caption).foregroundColor(.red)
      }
      if infoMessage != nil {
        Text(infoMessage!).font(.caption).foregroundColor(.green)
      }
    }
    .onAppear {
      self.info = self.loadInfo(self.name)
      self.editName = self.info?.title ?? ""
    }
    .actionSheet(isPresented: $showingActionSheet) {
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

  private func loadInfo(_ name: String) -> SurveyInfo? {
    return try? SurveyInfo(fromURL: SurveyBundle(name: self.name).infoURL)
  }

  private func updateTitle(_ title: String) {
    if name == surveyController.surveyName {
      info = surveyController.setTitle(title)
    } else {
      info = info?.with(title: title)
      if let info = info {
        do {
          try info.write(to: SurveyBundle(name: self.name).infoURL)
        } catch {
          errorMessage = error.localizedDescription
        }
      }
    }
  }

  private func createArchive() {
    // Creating an archive can be time consuming, and if it fails, then
    // we need to create it again.  This will check for a likely fail
    let archiveExist: Bool = {
      if let info = loadInfo(name) {
        let presumptiveArchiveName = info.title.sanitizedFileName
        let path = AppFile(type: .archive, name: presumptiveArchiveName).url.path
        return FileManager.default.fileExists(atPath: path)
      }
      return false
    }()
    if archiveExist {
      self.showingActionSheet = true
    } else {
      self.isExporting = true
      Survey.export(self.name, conflict: .fail) { error in
        self.isExporting = false
        if let error = error {
          if (error as NSError).code == NSFileWriteFileExistsError {
            self.showingActionSheet = true
          } else {
            self.errorMessage = error.localizedDescription
          }
        } else {
          self.infoMessage = "Exported survey"
        }
      }
    }
  }

  private func createArchiveKeepBoth() {
    self.isExporting = true
    Survey.export(self.name, conflict: .keepBoth) { error in
      self.isExporting = false
      if let error = error {
        self.errorMessage = error.localizedDescription
      } else {
        self.infoMessage = "Exported survey"
      }
    }
  }

  private func createArchiveReplace() {
    self.isExporting = true
    Survey.export(self.name, conflict: .replace) { error in
      self.isExporting = false
      if let error = error {
        self.errorMessage = error.localizedDescription
      } else {
        self.infoMessage = "Exported survey"
      }
    }
  }

}

struct SurveyItemView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyItemView(name: "survey1")
  }
}

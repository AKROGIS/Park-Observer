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
  @State private var isShowingDeleteAlert = false
  @State private var surveyFileAwaitingDeleteOk: AppFile? = nil

  var body: some View {
    Form {
      Section(footer: footer) {
        ForEach(fileNames, id: \.self) { name in
          FileItemView(file: AppFile(type: self.fileType, name: name))
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
      Section {
        if fileType == .map {
          NavigationLink(destination: OnlineMapListView()) {
            Text("Online Maps")
          }
        }
      }
    }
    .onAppear {
      self.errorMessage = nil
      self.refreshList()
      switch self.fileType {
      case .map:
        self.title = "Select a Map"
        break
      case .survey:
        self.title = "Select a Survey"
        break
      case .archive:
        self.title = "Survey Archives"
        break
      case .surveyProtocol:
        self.title = "Configuration Files"
        break
      }
    }
    .actionSheet(isPresented: $isShowingDeleteAlert) {
      ActionSheet(title: Text("Delete Survey?"),
                  message: Text("The changes in this survey have not been saved to an archive. They will be permanently deleted."),
                  buttons: [
                    ActionSheet.Button.destructive(
                      Text("Delete"), action: {
                        self.delete(self.surveyFileAwaitingDeleteOk)
                        self.surveyFileAwaitingDeleteOk = nil
                        self.refreshList()
                      }),
                    ActionSheet.Button.cancel(
                      Text("Cancel"),
                      action: {
                        self.surveyFileAwaitingDeleteOk = nil
                      })
                  ])
    }
    .navigationBarTitle(title)
  }

  private var footer: Text {
    Text(
      (fileType == .surveyProtocol ? "Tap to create a new survey. " : "")
        + "Swipe left to delete."
    )
  }

  private func delete(at offsets: IndexSet) {
    self.errorMessage = nil
    offsets.forEach { index in
      let name = fileNames[index]
      let file = AppFile(type: self.fileType, name: name)
      if isSurveyWithChanges(file) {
        surveyFileAwaitingDeleteOk = file
        isShowingDeleteAlert = true
      } else {
        delete(file)
      }
    }
    refreshList()
  }

  private func delete(_ file: AppFile?) {
    guard let file = file else { return }
    print("willDelete \(file)")
    surveyController.willDelete(file)
    print("finished willDelete \(file)")
    do {
      try FileManager.default.delete(file: file)
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  private func refreshList() {
    fileNames = FileManager.default.names(type: fileType).sorted {
      $0.localizedCompare($1) == .orderedAscending
    }
  }

  private func isSurveyWithChanges(_ file: AppFile) -> Bool {
    if file.type == .survey {
      let infoUrl = FileManager.default.surveyInfoURL(with: file.name)
      if let info = try? SurveyInfo(fromURL: infoUrl) {
        return info.state == .modified
      }
    }
    return false
  }

}


struct FileListView_Previews: PreviewProvider {
  static var previews: some View {
    FileListView(fileType: .map)
  }
}

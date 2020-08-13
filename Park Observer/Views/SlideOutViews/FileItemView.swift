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

struct FileItemView_Previews: PreviewProvider {
  static var previews: some View {
    FileItemView(file: AppFile(type: .map, name: "My Map"))
  }
}

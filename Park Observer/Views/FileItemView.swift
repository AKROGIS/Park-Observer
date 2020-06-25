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
      }
      else if file.type == .map {
        MapItemView(name: file.name)
      }
      else if file.type == .archive {
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
    //TODO: 1) Highlight the currently active map
    //TODO: 2) add thumbnail, date and author
    Text(name)
      .onTapGesture {
        self.surveyController.loadMap(name: self.name)
        //self.surveyController.slideOutMenuVisible.toggle()
    }
  }
}

struct SurveyItemView: View {
  var name: String
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) add export button
    //TODO: 2) replace file name with title from info; add icon, dates and status
    //TODO: 3) navigate to additional info about the survey
    //TODO: 4) Highlight the currently active survey
    Text(name)
      .onTapGesture {
        self.surveyController.loadSurvey(name: self.name)
        //self.surveyController.slideOutMenuVisible.toggle()
    }
  }
}

struct ArchiveItemView: View {
  var name: String
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) add import button
    //TODO: 2) add file date
    Text(name)
  }
}

struct ProtocolItemView: View {
  var name: String
  @EnvironmentObject var surveyController: SurveyController

  var body: some View {
    //TODO: 1) on tap, create a new survey from protocol
    //TODO: 2) Replace file name with title, version, date from SurveyProtocol
    //TODO: 3) navigate to additional info about the protocol
    Text(name)
  }
}


struct FileItemView_Previews: PreviewProvider {
    static var previews: some View {
      FileItemView(file: AppFile(type: .map, name: "My Map"))
    }
}

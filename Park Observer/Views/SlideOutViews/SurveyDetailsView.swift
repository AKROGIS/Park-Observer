//
//  SurveyDetailsView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct SurveyDetailsView: View {
  let name: String
  @State private var survey: Survey? = nil
  @State private var errorMessage: String? = nil

  var body: some View {
    Group {
      if survey == nil {
        if errorMessage == nil {
          Text("Waiting for survey to load")
        } else {
          Text(errorMessage!)
        }
      } else {
        Form {
          Section {
            InfoItemView(title: "Status", value: survey!.info.state.localizedString)
            InfoItemView(title: "Created", value: formatDate(survey!.info.creationDate))
            InfoItemView(title: "Last modified", value: formatDate(survey!.info.modificationDate))
            InfoItemView(title: "Last Exported", value: formatDate(survey!.info.exportDate))
            InfoItemView(title: "Created by", value: "Park Observer v\(survey!.info.version)")
            InfoItemView(title: "File name", value: name)
          }
          Section {
            InfoItemView(title: "Observations", value: formatCount(survey!.observationCount))
            InfoItemView(title: "Tracks", value: formatCount(survey!.trackCount))
            InfoItemView(title: "GPS points", value: formatCount(survey!.gpsCount))
            InfoItemView(title: "First point", value: formatDate(survey!.dateOfFirstGpsPoint))
            InfoItemView(title: "Last point", value: formatDate(survey!.dateOfLastGpsPoint))
            InfoItemView(
              title: "GPS Points since last export",
              value: formatCount(survey!.gpsCountSinceArchive))
          }
          Section {
            NavigationLink(
              destination: ProtocolDetailsView(
                name: "Protocol file", url: SurveyBundle(name: name).protocolURL)
            ) {
              Text("Protocol File")
            }
          }
        }
      }
    }.navigationBarTitle(survey?.info.title ?? "Unknown")
      .onAppear {
        Survey.load(self.name) { result in
          switch result {
          case .success(let survey):
            self.survey = survey
            self.errorMessage = nil
            break
          case .failure(let error):
            self.survey = nil
            self.errorMessage = error.localizedDescription
            break
          }
        }
      }

  }

  private func formatDate(_ date: Date?) -> String {
    if let date = date {
      return date.shortDateMediumTime
    }
    return "Not specified"
  }

  private func formatCount(_ n: Int?) -> String {
    if let n = n {
      return "\(n)"
    }
    return "Unknown"
  }

}

struct InfoItemView: View {
  let title: String
  let value: String

  var body: some View {
    VStack(alignment: .leading) {
      Text(title).font(.caption).foregroundColor(.secondary)
      Text(value)
    }
  }
}

struct SurveyDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    SurveyDetailsView(name: "survey1")
  }
}

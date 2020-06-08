//
//  Formatters.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/20/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// A collection of extensions on existing types for formatting them as text in various ways.
/// Also contains a file private Date Formatting Helper class (described below)
/// There is no public state in this file

import Foundation  // For Calendar, Date and DateFormatter

//MARK: - DateFormattingHelper

/// A helper class with a static shared singleton property for reusing the date formatters.
/// The singleton caches dateformatter objects that are reportedly expensive to create.
/// These dateformatters will be called thousands of times in a loop during CSV creation
/// so it makes sense to not create new ones for every date that needs formatting.
/// The singleton (static property) is lazily initialized (by default), so it will not be created until
/// the first reference. When the singleton is initialized, it will create the dateformatters.
/// The singleton and dateformatters will remain alive for the duration of the app's life.
/// The state is immutable and private (except singleton instance which can only be accessed
/// by the date extensions in this file)

fileprivate class DateFormattingHelper {

  static let shared = DateFormattingHelper()

  private let utcIsoDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    return dateFormatter
  }()

  private let localIsoDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS' 'z"
    return dateFormatter
  }()

  func formatUtcIso(_ date: Date) -> String {
    return utcIsoDateFormatter.string(from: date)
  }

  func formatLocalIso(_ date: Date) -> String {
    return localIsoDateFormatter.string(from: date)
  }

}

//MARK: - String Formatting

extension String {

  var escapeForCsv: String {
    return "\"" + self.replacingOccurrences(of: "\"", with: "\"\"") + "\""
  }

  static func formatOptional(format: String, value: CVarArg?) -> String {
    return value == nil ? "" : String(format: format, value!)
  }
}

//MARK: - Date Formatting

extension Date {

  static func julianDate(timestamp: Date?) -> (year: Int?, day: Int?) {
    guard let date = timestamp else {
      return (year: nil, day: nil)
    }
    let gregorian = Calendar(identifier: .gregorian)
    let year = gregorian.component(.year, from: date)
    let day = gregorian.ordinality(of: .day, in: .year, for: date)
    return (year: year, day: day)
  }

  var asIso8601UTC: String {
    return DateFormattingHelper.shared.formatUtcIso(self)
  }

  var asIso8601Local: String {
    return DateFormattingHelper.shared.formatLocalIso(self)
  }

}

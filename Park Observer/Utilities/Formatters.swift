//
//  Formatters.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/20/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation  // For Calendar, Date and DateFormatter

//MARK: - DateFormattingHelper

/// A helper class with a shared singleton property for reusing the date formatters
/// date formatting for CSV creation will be called in a loop thousands of times
/// and creating a dateformatter is reportedly expensive
class DateFormattingHelper {

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

  func formatUtcIso(_ date: Date?) -> String? {
    guard let date = date else { return nil }
    return utcIsoDateFormatter.string(from: date)
  }

  func formatLocalIso(_ date: Date?) -> String? {
    guard let date = date else { return nil }
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

}

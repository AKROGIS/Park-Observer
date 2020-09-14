//
//  DecodingError.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/4/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// An extension on DecodingError (from standard library) to implement the computed properties for
/// the LocalizedError protocol; DecodingError is already conformant, but the
/// default properties return empty strings
/// Extension cannot create new state.

extension DecodingError {
  public var errorDescription: String {
    switch self {
    case .dataCorrupted(_):
      return "Data Corrupted"
    case .keyNotFound(_, _):
      return "Property Not Found"
    case .typeMismatch(_, _):
      return "Type Mismatch"
    case .valueNotFound(_, _):
      return "Value Not Found"
    @unknown default:
      return "Unknown Decoding Error"
    }
  }

  public var failureReason: String {
    switch self {
    case .dataCorrupted(let context):
      let location = path(for: context)
      let locationMessage = "\(context.debugDescription) at \(location)."
      return location.isEmpty ? context.debugDescription : locationMessage
    case .keyNotFound(let key, let context):
      let property = name(of: key)
      let location = path(for: context)
      return "\"\(property)\" missing in \(location.isEmpty ? "top of document" : location )."
    case .typeMismatch(_, let context):
      let location = path(for: context)
      let locationMessage = "\(context.debugDescription) at \(location)."
      return location.isEmpty ? context.debugDescription : locationMessage
    case .valueNotFound(_, let context):
      let location = path(for: context)
      let locationMessage = "\(context.debugDescription) at \(location)."
      return location.isEmpty ? context.debugDescription : locationMessage
    @unknown default:
      return "Reason unknown"
    }
  }

  var recoverySuggestion: String {
    return "Fix the error in the file and reload."
  }

  private func name(of key: CodingKey) -> String {
    if let value = key.intValue { return "Item #\(value)" }
    return key.stringValue
  }

  private func path(for context: Context) -> String {
    return context.codingPath.map { prop in
      if let index = prop.intValue {
        return "[\(index)]"
      } else {
        return prop.stringValue
      }
    }.joined(separator: ".").replacingOccurrences(of: ".[", with: "[")
  }
}

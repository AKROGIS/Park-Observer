//
//  MissionTotalizer.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// An object used to define the text summarizing the mission so far.
struct MissionTotalizer: Codable {

  /// The names of attributes that are 'watched'. When one of them changes, the totalizer resets.
  let fields: [String]

  /// The size (in points) of the font used for the totalizer text.
  let fontSize: Double

  /// Indicate if the total distance/time while not 'observing' should be displayed.
  let includeOff: Bool

  /// Indicate if the total distance/time while 'observing' should be displayed.
  let includeOn: Bool

  /// Indicate if the total distance/time regardless of 'observing' status should be displayed.
  let includeTotal: Bool

  /// The units for the quantities displayed in the totalizer.
  let units: TotalizerUnits

  enum CodingKeys: String, CodingKey {
    case fields = "fields"
    case fontSize = "fontsize"
    case includeOff = "includeoff"
    case includeOn = "includeon"
    case includeTotal = "includetotal"
    case units = "units"
  }

  /// The units for the quantities displayed in the totalizer.
  enum TotalizerUnits: String, Codable {
    case kilometers = "kilometers"
    case miles = "miles"
    case minutes = "minutes"
  }

}

//MARK: - MissionTotalizer Codable
// Custom decoding to do array checking:
// Fields must have at least one element,
//   and all elements must be unique
// Also a good time to set default values

extension MissionTotalizer {

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let fields = try container.decode([String].self, forKey: .fields)
    let fontSize = try container.decodeIfPresent(Double.self, forKey: .fontSize) ?? 14.0
    let includeOff = try container.decodeIfPresent(Bool.self, forKey: .includeOff) ?? false
    let includeOn = try container.decodeIfPresent(Bool.self, forKey: .includeOn) ?? true
    let includeTotal = try container.decodeIfPresent(Bool.self, forKey: .includeTotal) ?? false
    let units = try container.decodeIfPresent(TotalizerUnits.self, forKey: .units) ?? .kilometers
    // Validate fields and fontSize
    if fields.count == 0 {
      throw ParsingError.arrayEmpty //TODO: Throw decoding error with context
    }
    if Set(fields).count != fields.count {
      throw ParsingError.nonuniqueArray //TODO: Throw decoding error with context
    }
    if fontSize < 0 {
      throw ParsingError.negativeNumber //TODO: Throw decoding error with context
    }
    self.init(
      fields: fields,
      fontSize: fontSize,
      includeOff: includeOff,
      includeOn: includeOn,
      includeTotal: includeTotal,
      units: units)
  }

  enum ParsingError: Error {
    case arrayEmpty
    case nonuniqueArray
    case negativeNumber
  }
}


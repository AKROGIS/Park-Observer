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
  let fontsize: Double?

  /// Indicate if the total distance/time while not 'observing' should be displayed.
  let includeoff: Bool?

  /// Indicate if the total distance/time while 'observing' should be displayed.
  let includeon: Bool?

  /// Indicate if the total distance/time regardless of 'observing' status should be displayed.
  let includetotal: Bool?

  /// The units for the quantities displayed in the totalizer.
  let units: TotalizerUnits?

  enum CodingKeys: String, CodingKey {
    case fields = "fields"
    case fontsize = "fontsize"
    case includeoff = "includeoff"
    case includeon = "includeon"
    case includetotal = "includetotal"
    case units = "units"
  }

  /// The units for the quantities displayed in the totalizer.
  enum TotalizerUnits: String, Codable {
    case kilometers = "kilometers"
    case miles = "miles"
    case minutes = "minutes"
  }

}

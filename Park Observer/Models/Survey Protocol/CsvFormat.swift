//
//  CsvFormat.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// Immutable structs and decoders for representing a portion of the configuration file (see SurveyProtocol.swift)

import Foundation

// MARK: - CSV

/// The format for exporting survey data to CSV files.
struct CsvFormat: Codable {

  /// Describes how to build the observer and feature point feature classes from the CSV file containing the observed features.
  let features: Features

  /// Describes how to build the GPS point feature class from the CSV file containing the GPS points.
  let gpsPoints: GpsPoints

  /// Describes how to build the track log feature class from the CSV file containing the tracklogs and mission properties.
  let trackLogs: TrackLogs

  enum CodingKeys: String, CodingKey {
    case features = "features"
    case gpsPoints = "gps_points"
    case trackLogs = "track_logs"
  }

  // MARK: - CSV Format Features

  /// Describes how to build the observer and feature point feature classes from the CSV file containing the observed features.
  struct Features: Codable {

    /// The column indices from the csv header, starting with zero, for the columns containing the data for the observed feature tables.
    let featureFieldMap: [Int]

    /// A list of the field names from the csv header that will create the observed feature tables.
    let featureFieldNames: [String]

    /// A list of the field types for each column listed in the 'feature_field_names' property.
    let featureFieldTypes: [FieldType]

    /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the feature.
    let featureKeyIndexes: [Int]

    /// The header of the CSV file; a list of the column names in order.
    let header: String

    /// The column indices from the csv header, starting with zero, for the columns containing the data for the observer table.
    let obsFieldMap: [Int]

    /// A list of the field names from the csv header that will create the observed feature table.
    let obsFieldNames: [String]

    /// A list of the field types for each column listed in the 'obs_field_names' property.
    let obsFieldTypes: [FieldType]

    /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the observer.
    let obsKeyIndexes: [Int]

    /// The name of the table in the esri geodatabase that will contain the data for the observer of the features.
    let obsName: String

    enum CodingKeys: String, CodingKey {
      case featureFieldMap = "feature_field_map"
      case featureFieldNames = "feature_field_names"
      case featureFieldTypes = "feature_field_types"
      case featureKeyIndexes = "feature_key_indexes"
      case header = "header"
      case obsFieldMap = "obs_field_map"
      case obsFieldNames = "obs_field_names"
      case obsFieldTypes = "obs_field_types"
      case obsKeyIndexes = "obs_key_indexes"
      case obsName = "obs_name"
    }
  }

  // MARK: - CSV Format GpsPoints

  /// Describes how to build the GPS point feature class from the CSV file containing the GPS points.
  struct GpsPoints: Codable {
    /// A list of the field names in the header of the CSV file in order.
    let fieldNames: [String]

    /// A list of the field types in the columns of the CSV file in order.
    let fieldTypes: [FieldType]

    /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the point.
    let keyIndexes: [Int]

    /// The name of the csv file, and the table in the esri geodatabase.
    let name: String

    enum CodingKeys: String, CodingKey {
      case fieldNames = "field_names"
      case fieldTypes = "field_types"
      case keyIndexes = "key_indexes"
      case name = "name"
    }
  }

  // MARK: - CSV Format TrackLogs

  /// Describes how to build the track log feature class from the CSV file containing the tracklogs and mission properties.
  struct TrackLogs: Codable {

    /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the last point in the tracklog.
    let endKeyIndexes: [Int]

    /// A list of the field names in the header of the CSV file in order.
    let fieldNames: [String]

    /// A list of the field types in the columns of the CSV file in order.
    let fieldTypes: [FieldType]

    /// The name of the csv file, and the table in the esri geodatabase.
    let name: String

    /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the first point in the tracklog.
    let startKeyIndexes: [Int]

    enum CodingKeys: String, CodingKey {
      case endKeyIndexes = "end_key_indexes"
      case fieldNames = "field_names"
      case fieldTypes = "field_types"
      case name = "name"
      case startKeyIndexes = "start_key_indexes"
    }
  }

  // MARK: - CSV Format FieldType

  /// Describes the data type for a column in the CSV.  Corresponds to parameter values in the esri create geodatabase table tool
  enum FieldType: String, Codable {
    case date = "DATE"
    case double = "DOUBLE"
    case short = "SHORT"
    case text = "TEXT"
  }

}

extension CsvFormat {

  static private var v1FormatData = Data(
    """
    {
      "gps_points":{
        "name":"GpsPoints",
        "field_names":["Timestamp", "Latitude", "Longitude", "Datum", "Error_radius_m", "Course", "Speed_mps", "Altitude_m", "Vert_error_m"],
        "field_types":["TEXT", "DOUBLE", "DOUBLE", "TEXT", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE"],
        "key_indexes":[0,2,1]
      },
      "track_logs":{
        "name":"TrackLogs",
        "field_names":["Observing", "Start_UTC", "Start_Local", "Year", "Day_of_Year", "End_UTC", "End_Local", "Duration_sec", "Start_Latitude", "Start_Longitude", "End_Latitude", "End_Longitude", "Datum", "Length_m"],
        "field_types":["TEXT", "TEXT", "TEXT", "SHORT", "SHORT", "TEXT", "TEXT", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE", "TEXT", "DOUBLE"],
        "start_key_indexes":[1,9,8],
        "end_key_indexes":[5,11,10]
      },
      "features":{
        "header": "Timestamp_UTC,Timestamp_Local,Year,Day_of_Year,Feature_Latitude,Feature_Longitude,Observer_Latitude,Observer_Longitude,Datum,Map_Name,Map_Author,Map_Date,Angle,Distance,Perp_Meters",
        "feature_field_names":["Timestamp_UTC", "Timestamp_Local", "Year", "Day_of_Year", "Latitude", "Longitude", "Datum"],
        "feature_field_types":["DATE", "DATE", "SHORT", "SHORT", "DOUBLE", "DOUBLE", "TEXT"],
        "feature_field_map":[0,1,2,3,4,5,8],
        "feature_key_indexes":[0,5,4],
        "obs_name":"Observations",
        "obs_field_names":["Timestamp_UTC", "Timestamp_Local", "Year", "Day_of_Year", "Map_Name", "Map_Author", "Map_Date", "Angle", "Distance", "Perp_meters", "Latitude", "Longitude", "Datum"],
        "obs_field_types":["TEXT", "TEXT", "SHORT", "SHORT", "TEXT", "TEXT", "TEXT", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE", "TEXT"],
        "obs_field_map":[0,1,2,3,9,10,11,12,13,14,6,7,8],
        "obs_key_indexes":[0,11,10]
      }
    }
    """.utf8)

  static func defaultFormat(for version: Int) throws -> CsvFormat {
    switch version {
    default:
      return try JSONDecoder().decode(CsvFormat.self, from: v1FormatData)
    }
  }
}

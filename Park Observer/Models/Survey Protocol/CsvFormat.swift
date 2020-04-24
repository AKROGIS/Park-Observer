//
//  CsvFormat.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation

// MARK: - CSV

/// The format for exporting survey data to CSV files.
struct CsvFormat: Codable {

  /// Describes how to build the observer and feature point feature classes from the CSV file containing the observed features.
  let features: CSVFeatures

  /// Describes how to build the GPS point feature class from the CSV file containing the GPS points.
  let gpsPoints: CSVGpsPoints

  /// Describes how to build the track log feature class from the CSV file containing the tracklogs and mission properties.
  let trackLogs: CSVTrackLogs

  enum CodingKeys: String, CodingKey {
    case features = "features"
    case gpsPoints = "gps_points"
    case trackLogs = "track_logs"
  }
}

// MARK: - CSVFeatures

/// Describes how to build the observer and feature point feature classes from the CSV file containing the observed features.
struct CSVFeatures: Codable {

  /// The column indices from the csv header, starting with zero, for the columns containing the data for the observed feature tables.
  let featureFieldMap: [Int]

  /// A list of the field names from the csv header that will create the observed feature tables.
  let featureFieldNames: [String]

  /// A list of the field types for each column listed in the 'feature_field_names' property.
  let featureFieldTypes: [CSVFieldType]

  /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the feature.
  let featureKeyIndexes: [Int]

  /// The header of the CSV file; a list of the column names in order.
  let header: String

  /// The column indices from the csv header, starting with zero, for the columns containing the data for the observer table.
  let obsFieldMap: [Int]

  /// A list of the field names from the csv header that will create the observed feature table.
  let obsFieldNames: [String]

  /// A list of the field types for each column listed in the 'obs_field_names' property.
  let obsFieldTypes: [CSVFieldType]

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

// MARK: - CSVGpsPoints

/// Describes how to build the GPS point feature class from the CSV file containing the GPS points.
struct CSVGpsPoints: Codable {
  /// A list of the field names in the header of the CSV file in order.
  let fieldNames: [String]

  /// A list of the field types in the columns of the CSV file in order.
  let fieldTypes: [CSVFieldType]

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

// MARK: - CSVTrackLogs

/// Describes how to build the track log feature class from the CSV file containing the tracklogs and mission properties.
struct CSVTrackLogs: Codable {

  /// The column indices, starting with zero, for the columns containing the time, x and y coordinates of the last point in the tracklog.
  let endKeyIndexes: [Int]

  /// A list of the field names in the header of the CSV file in order.
  let fieldNames: [String]

  /// A list of the field types in the columns of the CSV file in order.
  let fieldTypes: [CSVFieldType]

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

/// Describes the data type for a column in the CSV.  Corresponds to parameter values in the esri create geodatabase table tool
enum CSVFieldType: String, Codable {
  case date = "DATE"
  case double = "DOUBLE"
  case short = "SHORT"
  case text = "TEXT"
}

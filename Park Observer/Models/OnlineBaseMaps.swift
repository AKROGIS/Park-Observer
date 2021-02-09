//
//  OnlineBaseMaps.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/26/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS

enum OnlineBaseMaps {

  static let esri: [String: AGSBasemapStyle] = [
    "Esri Community": .arcGISCommunity,
    "Esri Dark Gray": .arcGISDarkGray,
    "Esri Dark Gray (No Labels)": .arcGISDarkGrayBase,
    "Esri Hillshade Light": .arcGISHillshadeLight,
    "Esri Hillshade Dark": .arcGISHillshadeDark,
    "Esri Imagery": .arcGISImagery,
    "Esri Imagery (No Labels)": .arcGISImageryStandard,
    "Esri Light Gray": .arcGISLightGray,
    "Esri Light Gray (No Labels)": .arcGISLightGrayBase,
    "Esri Navigation": .arcGISNavigation,
    "Esri Navigation Night": .arcGISNavigationNight,
    "Esri Oceans": .arcGISOceans,
    "Esri Oceans (No Labels)": .arcGISOceansBase,
    "Esri Streets": .arcGISStreets,
    "Esri Streets Charted Territory": .arcGISChartedTerritory,
    "Esri Streets Colored Pencil": .arcGISColoredPencil,
    "Esri Streets Mid Century": .arcGISMidcentury,
    "Esri Streets Modern Antique": .arcGISModernAntique,
    "Esri Streets Newspaper": .arcGISNewspaper,
    "Esri Streets Night": .arcGISStreetsNight,
    "Esri Streets Nova": .arcGISNova,
    "Esri Streets Relief": .arcGISStreetsRelief,
    "Esri Terrain": .arcGISTerrain,
    "Esri Topographic": .arcGISTopographic,
  ]

}

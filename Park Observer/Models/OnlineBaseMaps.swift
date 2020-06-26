//
//  OnlineBaseMaps.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/26/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS

enum OnlineBaseMaps {

  static let esri: [String: () -> AGSBasemap] = [
    "Esri Dark Gray Canvas Vector": AGSBasemap.darkGrayCanvasVector,
    "Esri Imagery": AGSBasemap.imagery,
    "Esri Imagery With Labels": AGSBasemap.imageryWithLabels,
    "Esri Imagery With Labels Vector": AGSBasemap.imageryWithLabelsVector,
    "Esri Light Gray Canvas": AGSBasemap.lightGrayCanvas,
    "Esri Light Gray Canvas Vector": AGSBasemap.lightGrayCanvasVector,
    "Esri National Geographic": AGSBasemap.nationalGeographic,
    "Esri Navigation Vector": AGSBasemap.navigationVector,
    "Esri Oceans": AGSBasemap.oceans,
    "Esri Open Street Map": AGSBasemap.openStreetMap,
    "Esri Streets": AGSBasemap.streets,
    "Esri Streets Night Vector": AGSBasemap.streetsNightVector,
    "Esri Streets Vector": AGSBasemap.streetsVector,
    "Esri Streets With Relief Vector": AGSBasemap.streetsWithReliefVector,
    "Esri Terrain With Labels": AGSBasemap.terrainWithLabels,
    "Esri Terrain With Labels Vector": AGSBasemap.terrainWithLabelsVector,
    "Esri Topographic": AGSBasemap.topographic,
    "Esri Topographic Vector": AGSBasemap.topographicVector,
  ]

}

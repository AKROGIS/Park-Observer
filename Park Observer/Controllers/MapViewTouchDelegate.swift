//
//  MapViewTouchDelegate.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 3/30/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS  // For AGSGeoView, AGSGeoViewTouchDelegate, AGSGraphic, AGSPoint
import Foundation  // For NSObject
import SwiftUI  // For Alert(), Text()

// Notes:
// The _didTouchDown_ event allows the delegate the ability to "steal" subsequent events from the map view, so we
// can for example use drag events to move a graphic, instead of letting the map view pan the map. There are two
// problems with this approach: 1) If there are multiple graphics at the touch location, I need to present the user
// with a choice to know which graphic to move, at that point the touch cycle is over.  2) If I find a single graphic,
// and signal I want to steal events, I will get _didTouchDrag_ events followed by a _didCancelTouchDrag_ or a
// _didTouchUp_ event but no _didTap_ event. (I only get a _didTap_ event if I am not stealing touch events.) This
// makes sense. But, I want to display an info callout if the user taps (_didTap, or _didTouchDown_ followed by
// _didTouchUp_), and drag/move the graphic if I get a _didTouchDown, 1 or more _didTouchDrag_, then a _didTouchUp_.
// If there is none (or a few, or very small distance) _didTouchDrag_ events, then maybe this was an "accidental"
// move, and the user was actually trying to tap (this happens easilly in an unstable environment like a vehicle.)
// This becomes a difficult problem of guessing the user's intention. 3) I want the system to handle panning,
// zooming and other touch events, so I need to be careful to not "steal" the events if I'm not going to use them.
// A solution these problems is to skip the _didTouch*_ events, and just monitor _didTap_ events. On the
// info display I can add a button to allow the user to move the graphic by providing just the final destination via
// an additional single tap.  I will do a move if there is a "selected" graphic when I get the _didTap_, otherwise
// will process the _didTap_ as usual to select a graphic and display its info.
// The only draw back is that there is a 1/2 second delay before I get the tap event, presumably to differentiate
// a simple tap from other touvh events.

class MapViewTouchDelegate: NSObject, AGSGeoViewTouchDelegate {

  private let surveyController: SurveyController

  private var movingGraphic: AGSGraphic? = nil

  init(surveyController: SurveyController) {
    self.surveyController = surveyController
    super.init()
  }

  func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {

    if let graphic = movingGraphic {
      graphic.move(to: mapPoint)
      movingGraphic = nil
    }

    geoView.hitTest(at: screenPoint) { foundGraphics in
      switch foundGraphics.count {
      case 0:
        self.addItem(at: mapPoint)
        break
      case 1:
        self.displayInfo(for: foundGraphics[0])
        break
      case 2..<Int.maxGraphics:
        self.displaySelector(for: foundGraphics)
        break
      default:
        self.alertTooManyGraphics(count: foundGraphics.count)
      }
    }
  }

  private func addItem(at mapPoint: AGSPoint) {
    print("MapViewTouchDelegate.addItem not implemented yet")
  }

  private func displayInfo(for graphic: AGSGraphic) {
    print("MapViewTouchDelegate.displayInfo not implemented yet")
  }

  private func displaySelector(for graphics: [AGSGraphic]) {
    print("MapViewTouchDelegate.displaySelector not implemented yet")
  }

  private func alertTooManyGraphics(count: Int) {
    let message = "\(count) items at touch location. Zoom in to limit the number of items found."
    surveyController.alert = Alert(
      title: Text("Too Many Items Found"),
      message: Text(message),
      dismissButton: .default(Text("OK")))
    surveyController.showingAlert = true
  }

}

extension AGSGraphic {

  func move(to mapPoint: AGSPoint) {
    if self.geometry is AGSPoint {
      self.geometry = mapPoint
    }
  }

}

extension Int {
  static var maxGraphics: Int { return 6 }
}

extension AGSGeoView {

  func hitTest(at point: CGPoint, completion: @escaping ([AGSGraphic]) -> Void) {
    //TODO: adjust hit radius based on user selected control size
    let hitRadius = 22.0
    self.identifyGraphicsOverlays(
      atScreenPoint: point, tolerance: hitRadius, returnPopupsOnly: false,
      maximumResultsPerOverlay: .maxGraphics
    ) { (results, error) in
      if let error = error {
        print("GeoView Identify returned \(error.localizedDescription)")
        completion([AGSGraphic]())
        return
      } else if let results = results {
        //TODO: filter the results to exclude gpsPoints
        //TODO: if a tracklog is selected, return the related mission property graphic
        let graphics = results.reduce([AGSGraphic]()) { x, y in x + y.graphics }
        completion(graphics)
      }
    }
  }

}

//MARK: - Keep??

/*
extension MapViewTouchDelegate {

  //   private let calloutDelegate = CalloutDelegate()

  func oldStuff(geoView: AGSGeoView, mapPoint: AGSPoint, screenPoint: CGPoint) {
    // Force dismiss the callout
    geoView.callout.dismiss()

    // Move the selected graphic
    if let graphic = selectedGraphic {
      graphic.geometry = mapPoint
      selectedGraphic = nil
      return
    }
    // Hit test for graphic at tap location
    geoView.identifyGraphicsOverlays(
      atScreenPoint: screenPoint, tolerance: 22, returnPopupsOnly: false,
      maximumResultsPerOverlay: 20
    ) { (results, error) in
      if let error = error {
        print("GeoView Identify returned an error: \(error)")
        return
      }
      guard let results = results else {
        print("GeoView identify returned no results")
        return
      }
      if results.count == 0 {
        print("Adding a graphic at \(mapPoint)")
        // Add a layer if one does not exist
        if geoView.graphicsOverlays.count == 0 {
          let overlay = AGSGraphicsOverlay()
          geoView.graphicsOverlays.add(overlay)
        }
        // Add a graphic with attributes
        let graphic = AGSSimplegraphicSymbol(style: .circle, color: .red, size: 20)
        var attributes = [String: Any]()
        attributes["timestamp"] = Date()
        let graphic = AGSGraphic(geometry: mapPoint, symbol: graphic, attributes: attributes)
        let overlay = geoView.graphicsOverlays[0] as! AGSGraphicsOverlay
        overlay.graphics.add(graphic)
        return
      }
      if results.count == 1 && results[0].graphics.count == 1 {
        print("Present callout for graphic at \(mapPoint)")
        //TODO: Get the user to pick the layer/graphic they want to select
        let selected = results[0].graphics[0]
        geoView.callout.delegate = self.calloutDelegate
        geoView.callout.title = "Timestamp"
        geoView.callout.detail = "\(selected.attributes["timestamp"]!)"
        geoView.callout.show(for: selected, tapLocation: mapPoint, animated: true)
        self.selectedGraphic = selected
      } else {
        // Present a navigation list of graphics that were hit
        for i in (0..<results.count) {
          print("Found \(results[i].graphics.count) graphics in layer \(i)")
        }
      }
    }
  }
}


class CalloutDelegate: NSObject, AGSCalloutDelegate {

  func callout(_ callout: AGSCallout, willShowAtMapPoint mapPoint: AGSPoint) -> Bool {
    print("Callout will show at map point \(mapPoint)")
    return true
  }

  func didTapAccessoryButton(for callout: AGSCallout) {
    callout.dismiss()
  }

  func callout(_ callout: AGSCallout, willShowFor locationDisplay: AGSLocationDisplay) -> Bool {
    return false
  }

}
*/

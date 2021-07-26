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

// ArcGIS has suitable default actions for most MapView touch events:
//  pinch to zoom/rotate
//  double tap to zoom
//  drag to pan
//  long press to magnify
// There is no default action for tap.  Park Observer will provide that functionality.

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
// move, and the user was actually trying to tap (this happens easily in an unstable environment like a vehicle.)
// This becomes a difficult problem of guessing the user's intention. 3) I want the system to handle panning,
// zooming and other touch events, so I need to be careful to not "steal" the events if I'm not going to use them.
// A solution these problems is to skip the _didTouch*_ events, and just monitor _didTap_ events. On the
// info display I can add a button to allow the user to move the graphic by providing just the final destination via
// an additional single tap.  I will do a move if there is a "selected" graphic when I get the _didTap_, otherwise
// will process the _didTap_ as usual to select a graphic and display its info.
// The only draw back is that there is a 1/2 second delay before I get the tap event, presumably to differentiate
// a simple tap from other touch events.

class MapViewTouchDelegate: NSObject, AGSGeoViewTouchDelegate {

  private let surveyController: SurveyController

  init(surveyController: SurveyController) {
    self.surveyController = surveyController
    super.init()
  }

  func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint)
  {
    // Ignore all map touches if we don't have a survey
    guard surveyController.hasSurvey else { return }

    //Priority:
    // 1) Move to tap (if requested)
    // 2) Select feature for review/edit (if tap hits observation(s))
    // 3) Add Observation

    if surveyController.movingGraphic {
      surveyController.moveGraphic(to: mapPoint)
      return
    }

    geoView.hitTest(at: screenPoint) { foundGraphics in
      switch foundGraphics.count {
      case 0:
        self.surveyController.addObservation(at: mapPoint)
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

  private func displayInfo(for graphic: AGSGraphic) {
    // Always show observationView (even if no editable attributes) user may want to see
    // timestamp or location details; may want to delete or move an observation
    surveyController.selectedObservation = surveyController.observationPresenter(for: graphic)
    surveyController.showingObservationEditor = true
    surveyController.slideOutMenuVisible = true
  }

  private func displaySelector(for graphics: [AGSGraphic]) {
    // Show all graphics in observationSelector (even if no editable attributes)
    // User may want to see timestamp or location details; may want to delete or move an observation
    surveyController.selectedObservations = graphics.map {
      surveyController.observationPresenter(for: $0)
    }
    surveyController.showingObservationSelector = true
    surveyController.slideOutMenuVisible = true
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
        let layersToIgnore: [String] = [
          .layerNameGpsPoints, .layerNameTrackLogsOn, .layerNameTrackLogsOff,
        ]
        let graphics = results.reduce([AGSGraphic]()) { x, y in
          layersToIgnore.contains(y.graphicsOverlay.overlayID) ? x : x + y.graphics
        }
        completion(graphics)
      }
    }
  }

}

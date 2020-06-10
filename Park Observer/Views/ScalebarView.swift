//
//  ScalebarView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/8/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

// BUG: in UIViewRepresentable? (swift 5.1; iOS 13.3; Xcode 11.3)
// the @environment only returned the default value when this was a final class
// However that may preclude calls to update when the @ObservedObject changes
// See discussion in MapView.swift

struct ScalebarView: UIViewRepresentable {

  @EnvironmentObject var surveyController: SurveyController
  @Environment(\.darkMap) var darkMap

  func makeUIView(context: Context) -> Scalebar {
    print("darkMap in Make scalebar = \(darkMap)")
    // Set static properties on UIView
    let scalebar = Scalebar()
    scalebar.mapView = surveyController.mapView
    scalebar.style = .dualUnitLine
    scalebar.alignment = .left
    scalebar.font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.semibold)
    return scalebar
  }

  func updateUIView(_ view: Scalebar, context: Context) {
    print("darkMap in Update scalebar = \(darkMap)")
    view.textColor = darkMap ? UIColor.white : UIColor.black
    view.textShadowColor = (darkMap ? UIColor.black : UIColor.white).withAlphaComponent(0.80)
    view.lineColor = darkMap ? UIColor.white : UIColor.black
    view.shadowColor = (darkMap ? UIColor.black : UIColor.white).withAlphaComponent(0.80)
  }
}

struct ScalebarView_Previews: PreviewProvider {
  static var previews: some View {
    ScalebarView()
  }
}

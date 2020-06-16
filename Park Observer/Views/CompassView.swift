//
//  CompassView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/8/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This view draws a simple compass rose.
/// The red half of the needle is north (the south half is white or black).
/// It is drawn in an semi opaque circle.
/// The size of the view is determined by the frame the user attaches to it.
/// It has two required parameters:
/// 1) A double that is the rotation: 0 = North, 90 = East, ... Values from wrap from -inf. to +inf
/// 2) A darkMode boolean:
///   With darkMode = false, the enclosing circle is white and south is black (for use on a dark map)
///   With darkMode = true, the enclosing circle is black and south is white (for use on a light map)

import SwiftUI

struct CompassView: View {
  let rotation: Double
  let darkMode: Bool

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Triangle()
          .fill(Color(.red))
          .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.34)
          .offset(x: 0.0, y: -0.17 * geometry.size.height)
        Triangle()
          .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.34)
          .offset(x: 0.0, y: -0.17 * geometry.size.height)
          .rotationEffect(Angle(degrees: 180.0))
      }
    }
    .foregroundColor(Color(darkMode ? .white : .black))
    .rotationEffect(Angle(degrees: rotation))
  }
}

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let apex = rect.minX + (rect.maxX - rect.minX) / 2.0
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: apex, y: rect.minY))

    return path
  }
}

struct CompassView_Previews: PreviewProvider {
  static var previews: some View {
    CompassView(rotation: 25.0, darkMode: false)
      .frame(width: 44, height: 44)
      .padding()
      .background(Color.purple)
  }
}

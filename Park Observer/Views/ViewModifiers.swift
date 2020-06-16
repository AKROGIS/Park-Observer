//
//  ViewModifiers.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

extension View {
  func mapButton(darkMode: Bool) -> some View {
    self.modifier(MapButton(darkMode: darkMode))
  }
}

struct MapButton: ViewModifier {
  let darkMode: Bool

  func body(content: Content) -> some View {
    content
      .frame(width: 44, height: 44)
      .background(Color(darkMode ? .black : .white).opacity(0.65))
      .clipShape(Circle())
      .overlay(Circle().stroke(Color(darkMode ? .black : .white), lineWidth: 3))
  }

}

struct ViewModifiers_Previews: PreviewProvider {
  static var previews: some View {
    Image(systemName: "map").font(.headline).mapButton(darkMode: true)
  }
}

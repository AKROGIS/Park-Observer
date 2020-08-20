//
//  TotalizerView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 7/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct TotalizerView: View {
  @ObservedObject var totalizer: Totalizer
  @EnvironmentObject var userSettings: UserSettings

  var body: some View {
    HStack {
      Text(totalizer.text)
        .padding(.vertical, 5)
        .padding(.leading)
        .font(.headline)
        .foregroundColor(userSettings.darkMapControls ? .black : .white)
        .shadow(color: userSettings.darkMapControls ? .white : .black, radius: 5.0)
      Spacer()
      Image(systemName: "xmark.circle.fill")
        .foregroundColor(userSettings.darkMapControls ? .black : .white)
        .padding(.trailing)
    }.background(
      //https://material.io/design/color/the-color-system.html#tools-for-picking-colors
      // Blue 50 - 500 #2196F3
      Color(red: 33.0 / 255.0, green: 150.0 / 255.0, blue: 253.0 / 255.0).opacity(0.7)
    )
    .onTapGesture {
      withAnimation { self.userSettings.showTotalizer = false }
    }
  }

}

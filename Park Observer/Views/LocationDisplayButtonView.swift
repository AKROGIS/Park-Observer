//
//  LocationDisplayButtonView.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/9/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct LocationDisplayButtonView: View {
  @Binding var locationDisplayOn: Bool

  var body: some View {
    Button(action: {
      self.locationDisplayOn.toggle()
    }) {
      (locationDisplayOn ? Image(systemName: "location") : Image(systemName: "location.slash"))
        .padding()
        .background(Color(.systemBackground))
        .clipShape(Circle())
    }
  }

}

struct LocationDisplayButtonView_Previews: PreviewProvider {
  static var previews: some View {
    LocationDisplayButtonView(locationDisplayOn: .constant(true))
  }
}

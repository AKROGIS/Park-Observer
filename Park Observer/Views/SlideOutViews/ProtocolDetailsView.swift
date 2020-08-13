//
//  ProtocolDetailsView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ProtocolDetailsView: View {
  let name: String

  var body: some View {
    Text("Protocol Details for: \(name)")
  }

}

struct ProtocolDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    ProtocolDetailsView(name: "protocol1")
  }
}

//
//  Symbology.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS

struct Symbology: Codable {
  let renderer: AGSRenderer
}
extension Symbology {
  init(from decoder: Decoder) throws {
    let renderer = AGSSimpleRenderer()
    self.init(renderer: renderer)
  }

  func encode(to encoder: Encoder) throws {
    //FIXME: Implement
  }
}

extension Symbology {
  init(_ type: SimpleSymbol, size: Double, color:UIColor) {
    var symbol: AGSSymbol
    switch type {
    case .point:
      symbol = AGSSimpleMarkerSymbol(style: .circle, color: color, size: CGFloat(size))
      break
    case .line:
      symbol = AGSSimpleLineSymbol(style: .solid, color: color, width: CGFloat(size))
      break
    case .text:
      let textSymbol = AGSTextSymbol()
      textSymbol.color = color
      textSymbol.size = CGFloat(size)
      symbol = textSymbol
      break
    }
    self.init(renderer: AGSSimpleRenderer(symbol: symbol))
  }
}

enum SimpleSymbol {
  case point
  case line
  case text
}

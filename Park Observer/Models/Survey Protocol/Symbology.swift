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

//MARK: - Default Renderers

extension AGSSimpleRenderer {
  enum DefaultRenderer {
    /// points for observed features
    case features
    /// points for mission properties, i.e. tracklog observations
    case mission
    /// gps points
    case gps
    /// line segments while tracklogging but not observing, i.e. off transet
    case onTransect
    /// line segments while tracklogging but not observing, i.e. off transet
    case offTransect
  }

  convenience init(for style: DefaultRenderer, color: UIColor? = nil, size: Double? = nil) {
    switch style {
    case .features:
      let color = color ?? .red
      let size = CGFloat(size ?? 14.0)
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: color, size: size)
      self.init(symbol: symbol)
    case .mission:
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: .green, size: 12.0)
      self.init(symbol: symbol)
    case .gps:
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: .blue, size: 6.0)
      self.init(symbol: symbol)
    case .onTransect:
      let symbol = AGSSimpleLineSymbol(style: .solid, color: .red, width: 3.0)
      self.init(symbol: symbol)
    case .offTransect:
      let symbol = AGSSimpleLineSymbol(style: .solid, color: .gray, width: 1.5)
      self.init(symbol: symbol)
    }
  }

}

//MARK: - Simple Symbology
// For support of symbology in version 1 of protocol

struct SimpleSymbology {
  let color: UIColor?
  let size: Double?
}

extension SimpleSymbology: Codable {

  enum CodingKeys: String, CodingKey {
    case color = "color"
    case size = "size"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var color: UIColor?
    if let hex = try container.decodeIfPresent(String.self, forKey: .color) {
      color = UIColor(hex: hex)
      //TODO: if color == nil then throw parsing error
    }
    var size: Double? = try container.decodeIfPresent(Double.self, forKey: .size)
    if size != nil && size! < 0 {
      size = nil
      //TODO: Throw parsing error
    }
    self.init(color: color, size: size)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(color?.hex6, forKey: .color)
    try container.encodeIfPresent(size, forKey: .size)
  }

}

//MARK: - UIColor
// Extend UIColor to read/write hex colors of the form: #RRGGBB (ignores alpha component)

extension UIColor {
  public convenience init?(hex: String) {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat

    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])

      if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
          b = CGFloat((hexNumber & 0x0000ff)) / 255

          self.init(red: r, green: g, blue: b, alpha: 1.0)
          return
        }
      }
    }

    return nil
  }

  var hex6: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return String(
        format: "#%02X%02X%02X", Int(red * 255.0), Int(green * 255.0), Int(blue * 255.0))
    } else {
      // Could not extract RGBA components:
      return "#??????"
    }
  }

}

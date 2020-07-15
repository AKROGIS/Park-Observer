//
//  ObservationForm.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation  // For NSObject, UUID, NSNumber, @objc
import SwiftUI  // For Binding
import UIKit  // For UIKeyboardType, UITextAutocapitalizationType

struct ObservationForm {
  let title: String
  let sections: [FormSection]
}

extension ObservationForm {
  init() {
    self.title = "No Observation"
    self.sections = []
  }
}

struct FormSection: Identifiable {
  let id = UUID()
  let header: String?
  let footer: String?
  let elements: [FormElement]
}

// [FormElement] will be used by ForEach, so FormElement needs to be identifiable
// Cannot conform to identifiable if I want to use it as an array element in FormSection
// "Protocol 'Identifiable' can only be used as a generic constraint because it has Self or associated type requirements"
protocol FormElement {
  var id: UUID { get }
}

struct DoubleElement: FormElement {
  let id = UUID()
  let label: String?
  var placeholder: String
  //Caution, distance (max-min) must fit within Double; therefore 0...Double.max is ok, but -1...Double.max is not
  let range: ClosedRange<Double>?
  let decimals: Int?
  let key: String
  let data: NSObject

  var binding: Binding<Double?> {
    return Binding<Double?>(
      get: {
        guard let v = self.data.value(forKey: self.key) as? NSNumber else { return nil }
        return v.doubleValue
      },
      set: { value in
        var newValue: NSNumber? = nil
        if let v = value { newValue = NSNumber(value: v) }
        self.data.setValue(newValue, forKey: self.key)
        //print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
      })
  }

}

struct IntElement: FormElement {
  let id = UUID()
  let label: String?
  let placeholder: String
  let showStepper: Bool
  //Caution, distance (max-min) must fit within Int; therefore 0...Int.max is ok, but -1...Int.max is not
  let range: ClosedRange<Int?>
  let key: String
  let data: NSObject

  var binding: Binding<Int?> {
    return Binding<Int?>(
      get: {
        guard let v = self.data.value(forKey: self.key) as? NSNumber else { return nil }
        return v.intValue
      },
      set: { value in
        var newValue: NSNumber? = nil
        if let v = value { newValue = NSNumber(value: v) }
        self.data.setValue(newValue, forKey: self.key)
        //print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
      })
  }

}

struct LabelElement: FormElement {
  let id = UUID()
  let label: String
}

struct PickerElement: FormElement {
  let id = UUID()
  let segmentedStyle: Bool
  let label: String?
  let choices: [String]
  let saveAsText: Bool
  let key: String
  let data: NSObject

  // Binds to the index of choices; anything out of range is ignored by UI; use -1 for nil (no selection)
  var binding: Binding<Int> {
    return Binding<Int>(
      get: {
        if self.saveAsText {
          guard let str = self.data.value(forKey: self.key) as? String else { return -1 }
          return self.choices.firstIndex(of: str) ?? -1
        } else {
          guard let v = self.data.value(forKey: self.key) as? NSNumber else { return -1 }
          return v.intValue
        }
      },
      set: { value in
        if self.saveAsText {
          let newValue = value < 0 || value >= self.choices.count ? nil : self.choices[value]
          self.data.setValue(newValue, forKey: self.key)
        } else {
          let newValue = value < 0 ? nil : NSNumber(value: value)
          self.data.setValue(newValue, forKey: self.key)
        }
        //print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
      })
  }

}

struct TextElement: FormElement {
  let id = UUID()
  let label: String?
  var placeholder: String
  var keyboard: UIKeyboardType
  var autoCapitalization: UITextAutocapitalizationType
  var disableAutoCorrect: Bool
  var lines: Int
  let key: String
  let data: NSObject

  var binding: Binding<String> {
    return Binding<String>(
      get: {
        return self.data.value(forKey: self.key) as? String ?? ""
      },
      set: { value in
        let newValue = value == "" ? nil : value
        self.data.setValue(newValue, forKey: self.key)
        //print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
      })
  }

}

struct ToggleElement: FormElement {
  let id = UUID()
  let label: String
  let key: String
  let data: NSObject

  var binding: Binding<Bool?> {
    return Binding<Bool?>(
      get: {
        guard let v = self.data.value(forKey: self.key) as? NSNumber else { return nil }
        return v.boolValue
      },
      set: { value in
        var newValue: NSNumber? = nil
        if let v = value { newValue = NSNumber(booleanLiteral: v) }
        self.data.setValue(newValue, forKey: self.key)
        //print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
      })
  }

}

extension Dialog {

  func form(with data: NSObject, fields: [Attribute]) -> ObservationForm {
    return ObservationForm(
      title: title, sections: sections.map { $0.formSection(with: data, fields: fields) })
  }

}

extension DialogSection {

  func formSection(with data: NSObject, fields: [Attribute]) -> FormSection {
    return FormSection(
      header: title, footer: nil,
      elements: elements.map { $0.formElement(with: data, fields: fields) })
  }

}

extension DialogElement {

  func formElement(with data: NSObject, fields: [Attribute]) -> FormElement {
    guard let bind = attributeType, let name = attributeName,
      let attribute = fields.first(where: { $0.name == name })
    else {
      if type == .label {
        return LabelElement(label: title ?? "No Text for Label")
      } else {
        return LabelElement(label: (title ?? "") + " - No attribute binding for \(type.rawValue)")
      }
    }
    let key = .attributePrefix + name
    switch type {
    case .switch:
      return ToggleElement(label: title ?? "", key: key, data: data)
    case .numberEntry:
      switch attribute.type {
      case .float, .double:
        let range = doubleRange(
          lowerBound: minimumValue, upperBound: maximumValue, isFloat: attribute.type == .float)
        return DoubleElement(
          label: title, placeholder: placeholder ?? "", range: range, decimals: fractionDigits,
          key: key, data: data)
      case .int16, .int32, .int64:
        let range = intRange(
          lowerBound: minimumValue, upperBound: maximumValue, type: attribute.type)
        return IntElement(
          label: title, placeholder: placeholder ?? "", showStepper: true, range: range, key: key,
          data: data)
      default:
        return LabelElement(label: (title ?? "") + " - None numeric attribute for \(type.rawValue)")
      }
    case .textEntry, .multilineText:
      return TextElement(
        label: title, placeholder: placeholder ?? "", keyboard: keyboardType,
        autoCapitalization: autocapitalizationType, disableAutoCorrect: disableAutocorrection,
        lines: type == .textEntry ? 1 : 5, key: key, data: data)
    case .stepper:
      let range = intRange(lowerBound: minimumValue, upperBound: maximumValue, type: attribute.type)
      return IntElement(
        label: title, placeholder: placeholder ?? "", showStepper: true, range: range, key: key,
        data: data)
    case .label:
      if let value = data.value(forKey: key) {
        return LabelElement(label: "\(title ?? "") \(value)")
      } else {
        return LabelElement(label: (title ?? "No Text for Label") + " - No value for \(key)")
      }
    case .defaultPicker, .segmentedPicker:
      return PickerElement(
        segmentedStyle: type == .segmentedPicker, label: title, choices: items ?? [],
        saveAsText: bind == .item, key: key, data: data)
    }
  }

  //TODO: Simplify: Building ranges is too complicated (only really needed for stepper)
  //It is very,very unlikely that anyone would put in a limit approaching the extremes
  //TODO: check lower < upper
  fileprivate func doubleRange(lowerBound: Double?, upperBound: Double?, isFloat: Bool)
    -> ClosedRange<Double>?
  {
    if let lower = lowerBound, let upper = upperBound {
      return lower...upper
    }
    if let lower = lowerBound {
      let upper: Double = {
        if isFloat {
          return Double(Float.greatestFiniteMagnitude)
        } else {
          if lower < 0 {
            return Double.greatestFiniteMagnitude - abs(lower)
          } else {
            return Double.greatestFiniteMagnitude
          }
        }
      }()
      return lower...upper
    }
    if let upper = upperBound {
      let lower: Double = {
        if isFloat {
          return Double(-Float.greatestFiniteMagnitude)
        } else {
          if upper > 0 {
            return -(Double.greatestFiniteMagnitude - upper)
          } else {
            return -Double.greatestFiniteMagnitude
          }
        }
      }()
      return lower...upper
    }
    return nil
  }

  fileprivate func intRange(lowerBound: Double?, upperBound: Double?, type: Attribute.AttributeType)
    -> ClosedRange<Int?>
  {
    switch type {
    case .int16:
      let lower = lowerBound?.toInt16() ?? Int16.min
      let upper = upperBound?.toInt16() ?? Int16.max
      return Int(lower)...Int(upper)
    case .int32:
      let lower = lowerBound?.toInt32() ?? Int32.min
      let upper = upperBound?.toInt32() ?? Int32.max
      return Int(lower)...Int(upper)
    case .int64:
      let lower = max((lowerBound?.toInt64() ?? Int64.min / 2), Int64.min / 2)
      let upper = min((upperBound?.toInt64() ?? Int64.max / 2), Int64.max / 2)
      return Int(lower)...Int(upper)
    default:
      return Int(Int64.min / 2)...Int(Int64.max / 2)
    }
  }
}

extension Double {
  func toInt64() -> Int64? {
    if self >= Double(Int64.min) && self < Double(Int64.max) {
      return Int64(self)
    } else {
      return nil
    }
  }

  func toInt32() -> Int32? {
    if self >= Double(Int32.min) && self < Double(Int32.max) {
      return Int32(self)
    } else {
      return nil
    }
  }

  func toInt16() -> Int16? {
    if self >= Double(Int16.min) && self < Double(Int16.max) {
      return Int16(self)
    } else {
      return nil
    }
  }

}

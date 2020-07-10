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

class FormData: NSObject {
  @objc dynamic var toggle1: NSNumber? = nil
  @objc dynamic var toggle2: NSNumber? = nil
  @objc dynamic var text1: String? = nil
  @objc dynamic var text2: String? = nil
  @objc dynamic var text3: String? = nil
  @objc dynamic var text4: String? = nil
  @objc dynamic var int1: NSNumber? = nil
  @objc dynamic var int2: NSNumber? = nil
  @objc dynamic var double1: NSNumber? = nil
  @objc dynamic var double2: NSNumber? = nil
  @objc dynamic var pickerText1: String? = nil
  @objc dynamic var pickerText2: String? = nil
  @objc dynamic var pickerInt1: NSNumber? = nil
  @objc dynamic var pickerInt2: NSNumber? = nil
}

struct ObservationForm {
  let title: String
  let sections: [FormSection]
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
        print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
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
        print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
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
        print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
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
        print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
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
        print("data[\(self.key)] set to \(self.data.value(forKey: self.key))")
      })
  }

}

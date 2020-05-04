//
//  Dialog.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Dialog

/// Describes the look and feel of the attribute editor.
struct Dialog: Codable {
  /// Determines if the sections in this form are grouped.  I.e. there is visual separation
  /// between sections. Default is false
  private let groupedOptional: Bool?

  /// A list of form elements collected into a single section.
  let sections: [DialogSection]

  /// The text (title) at the top of the editing form.
  let title: String

  enum CodingKeys: String, CodingKey {
    case groupedOptional = "grouped"
    case sections = "sections"
    case title = "title"
  }
}

// extension for defaults
extension Dialog {
  var grouped: Bool { groupedOptional ?? false }
}

// Validate Dialog with Attributes
extension Dialog {

  var allElements: [DialogElement] {
    sections.flatMap { $0.elements }
  }

  var allAttributeNames: [String] {
    return allElements.compactMap { $0.attributeName }
  }

  var allAttributeTypes: [DialogElement.Bind] {
    return allElements.compactMap { $0.attributeType }
  }

  func validate(with attributes: [Attribute]) -> ([String], [String]) {
    let names = allAttributeNames
    guard names.count > 0, attributes.count > 0 else {
      return ([], [])
    }
    guard let typesLookup = Attribute.typesLookup(from: attributes) else {
      // This will be null if the attribute names are not unique.
      // The decode should not allow creation of a list of non-unique attribute names
      // If it does happen, I cannot do the check, so I will return everything
      return (names, names)
    }
    let attributeNames = attributes.map { $0.name }
    let missing = names.filter { !attributeNames.contains($0) }
    let mismatchElements = allElements.filter { element in
      guard let name = element.attributeName else { return false }
      guard let type = typesLookup[name] else { return false }  // Names not found are covered above
      return !element.matches(attributeType: type)
    }
    let mismatch = mismatchElements.compactMap { $0.attributeName }
    return (missing, mismatch)
  }

}

// MARK: - DialogSection

/// A collection of form elements united on the form with an optional title.
struct DialogSection: Codable {
  /// A list of editable form elements like text boxes and option pickers.
  let elements: [DialogElement]

  /// The text (title) at the top of this section.
  let title: String?

  enum CodingKeys: String, CodingKey {
    case elements = "elements"
    case title = "title"
  }
}

// Extend DialogSection to add validation after decoding
extension DialogSection {

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let elements = try container.decode([DialogElement].self, forKey: .elements)
    let title = try container.decodeIfPresent(String.self, forKey: .title)

    // Validate all element attribute names are unique (case-insensitive)
    let names = elements.compactMap { $0.attributeName?.lowercased() }
    if Set(names).count < names.count {
      throw DecodingError.dataCorruptedError(
        forKey: .elements, in: container,
        debugDescription: "Cannot initialize \(DialogSection.self) with duplicate element names")
    }

    self.init(elements: elements, title: title)
  }
}

// MARK: - DialogElement

/// An editable form component like a text box or option picker.
struct DialogElement {
  /// A special string that encodes the type and attribute name of the data for this element.
  //let bind: String?
  let attributeType: Bind?

  let attributeName: String?

  /// Determines if and how a text box will auto capitalize the user's typing.
  let autocapitalizationType: UITextAutocapitalizationType

  /// The default value for a boolean control (0 = false, 1 = true) only used byQBooleanElement.
  let defaultBool: Bool?

  /// The zero based index of the intially selected item from the list of items.
  let defaultIndex: Int?

  /// The default number value for a QIntegerElement or QDecimalElement.
  let defaultNumber: Double?

  /// Determines if a text box will auto correct (fix spelling) the user's typing. (false)
  /// was a mirror of UITextAutocorrectionType which was one of "Default", "No", "Yes"
  let disableAutocorrection: Bool

  /// How many digits will be shown after the decimal point (for QDecimalElement only).
  let fractionDigits: Int?

  /// A list of choices for a picklist type element (QRadioElement or QSegmentedElement).
  let items: [String]?

  /// Determines what kind of keyboard will appear when text editing is required.
  let keyboardType: UIKeyboardType

  /// The maximum value allowed in QIntegerElement or QDecimalElement.
  let maximumValue: Double?

  /// The minimum value allowed in QIntegerElement or QDecimalElement.
  let minimumValue: Double?

  /// Sample text to put in a text box to suggest to the user what to enter.
  let placeholder: String?

  /// The name/prompt that describes the data in this form element.
  let title: String?

  /// One of a well defined set of names for specific form elements.
  let type: DialogElementType

  /// The different kinds of form elements.
  enum DialogElementType: String, Codable {
    /// An on/off switch; binds to .bool
    case `switch` = "QBooleanElement"

    /// A floating point number editor; limited by min/max and number of fractional digits; binds to .number (.double)
    case numberEntry = "QDecimalElement"

    /// A single line text editor; binds with .text
    case textEntry = "QEntryElement"

    /// An integer editor with stepper control; limited by min/max; binds to .number (.int)
    case stepper = "QIntegerElement"

    /// A non-editable text element with a header font; optionally binds with .id
    case label = "QLabelElement"

    /// A multi line text editor; binds with .text
    case multilineText = "QMultilineElement"

    /// A single selection picklist built from text strings in items; binds to .index or .item
    /// for long lists that appear as a new tableview
    case defaultPicker = "QRadioElement"

    /// A single selection picklist built from text strings in items; binds to .index or .item
    /// for short lists that can be displayed on one line in the form
    case segmentedPicker = "QSegmentedElement"
  }

  /// The type of value that the form element will produce for binding with the attributes
  enum Bind: String, Codable {
    /// Get the value of the form element as a Bool; Used with AttributeType.bool
    case bool = "boolValue"

    /// Get the value of the form element as an NSNumber; Used with Used with AttributeType.{100-600}
    case number = "numberValue"

    /// Get the value of the form element as an Int; Used with AttributeType.int*
    case index = "selected"

    /// Get the value of the form element as a String; Used with AttributeType.string
    case item = "selectedItem"

    /// Get the value of the form element as a String; Used with AttributeType.string
    case text = "textValue"

    /// Get the value of the form element as an Int; Used with AttributeType.id
    case id = "value"
  }

}

extension DialogElement {

  var defaultInt: Int? {
    defaultNumber.map { Int($0.rounded()) }
  }

  var minimumInt: Int? {
    minimumValue.map { Int($0.rounded()) }
  }

  var maximumInt: Int? {
    maximumValue.map { Int($0.rounded()) }
  }

  func matches(attributeType: Attribute.AttributeType) -> Bool {
    guard let bindType = self.attributeType else {
      return false
    }
    switch (bindType, self.type) {
    case (.id, .label):
      return attributeType == .id
    case (.bool, .switch):
      return attributeType == .bool
    case (.index, .defaultPicker), (.index, .segmentedPicker):
      return attributeType.isIntegral
    case (.item, .defaultPicker), (.item, .segmentedPicker):
      return attributeType == .string
    case (.number, .stepper):
      return attributeType.isIntegral
    case (.number, .numberEntry):
      return attributeType.isFractional
    case (.text, .textEntry), (.text, .multilineText):
      return attributeType == .string
    default:
      return false
    }
  }

}

//MARK: - DialogElement Codable

// Implement custom decoding to support types that do not implement Codable and
// to do additional property validation.
extension DialogElement: Codable {

  /// Names of the properties in JSON
  enum CodingKeys: String, CodingKey {
    case autocapitalizationType = "autocapitalizationType"
    case bind = "bind"
    case defaultBool = "boolValue"
    case defaultIndex = "selected"
    case defaultNumber = "numberValue"
    case disableAutocorrection = "autocorrectionType"
    case fractionDigits = "fractionDigits"
    case items = "items"
    case keyboardType = "keyboardType"
    case maximumValue = "maximumValue"
    case minimumValue = "minimumValue"
    case placeholder = "placeholder"
    case title = "title"
    case type = "type"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let defaultBoolAsInt = try container.decodeIfPresent(Int.self, forKey: .defaultBool)
    let defaultBool: Bool? = defaultBoolAsInt.map { $0 != 0 }
    let defaultIndex = try container.decodeIfPresent(Int.self, forKey: .defaultIndex)
    let defaultNumber = try container.decodeIfPresent(Double.self, forKey: .defaultNumber)
    let fractionDigits = try container.decodeIfPresent(Int.self, forKey: .fractionDigits)
    let items = try container.decodeIfPresent([String].self, forKey: .items)
    let maximumValue = try container.decodeIfPresent(Double.self, forKey: .maximumValue)
    let minimumValue = try container.decodeIfPresent(Double.self, forKey: .minimumValue)
    let placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
    let title = try container.decodeIfPresent(String.self, forKey: .title)
    let type = try container.decode(DialogElementType.self, forKey: .type)

    var autocapitalizationType: UITextAutocapitalizationType? = nil
    if let text = try container.decodeIfPresent(String.self, forKey: .autocapitalizationType) {
      autocapitalizationType = UITextAutocapitalizationType(text: text)
      if autocapitalizationType == nil {
        throw DecodingError.dataCorruptedError(
          forKey: .autocapitalizationType, in: container,
          debugDescription: "Cannot initialize \(UITextAutocapitalizationType.self) with \(text)")
      }
    }

    var disableAutocorrection = false
    if let text = try container.decodeIfPresent(String.self, forKey: .disableAutocorrection) {
      guard ["yes", "no", "default"].contains(text.lowercased()) else {
        throw DecodingError.dataCorruptedError(
          forKey: .disableAutocorrection, in: container,
          debugDescription: "Cannot initialize \(UITextAutocorrectionType.self) with \(text)")
      }
      disableAutocorrection = text.lowercased() == "no"
    }

    var keyboardType: UIKeyboardType? = nil
    if let text = try container.decodeIfPresent(String.self, forKey: .keyboardType) {
      keyboardType = UIKeyboardType(text: text)
      if keyboardType == nil {
        throw DecodingError.dataCorruptedError(
          forKey: .keyboardType, in: container,
          debugDescription: "Cannot initialize \(UIKeyboardType.self) with \(text)")
      }
    }

    var attributeType: Bind? = nil
    var attributeName: String? = nil
    if let bind = try container.decodeIfPresent(String.self, forKey: .bind) {
      guard bind.contains(":") else {
        throw DecodingError.dataCorruptedError(
          forKey: .bind, in: container, debugDescription: "Cannot initialize bind with \(bind)")
      }
      let bindParts = bind.split(separator: ":")
      guard bindParts.count == 2 else {
        throw DecodingError.dataCorruptedError(
          forKey: .bind, in: container, debugDescription: "Cannot initialize bind with \(bind)")
      }
      guard let type = Bind(rawValue: String(bindParts[0])) else {
        throw DecodingError.dataCorruptedError(
          forKey: .bind, in: container,
          debugDescription: "Cannot initialize bind with \(bind), the left side is invalid")
      }
      attributeType = type
      let maybeName = String(bindParts[1])
      guard Attribute.isValid(name: maybeName) else {
        throw DecodingError.dataCorruptedError(
          forKey: .bind, in: container,
          debugDescription: "Cannot initialize bind with \(bind), the right side is invalid")
      }
      attributeName = maybeName
    }

    // Validation

    if let min = minimumValue, let max = maximumValue {
      if max <= min {
        throw DecodingError.dataCorruptedError(
          forKey: .maximumValue, in: container,
          debugDescription:
            "Cannot initialize Element because maximumValue \(max) must be greater than minimumValue \(min)"
        )
      }
    }
    if let min = minimumValue, let def = defaultNumber {
      if def < min {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultNumber, in: container,
          debugDescription:
            "Cannot initialize Element because numberValue \(def) must be greater than minimumValue \(min)")
      }
    }
    if let max = maximumValue, let def = defaultNumber {
      if def > max {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultNumber, in: container,
          debugDescription:
            "Cannot initialize Element because numberValue \(def) must be less than maximumValue \(max)")
      }
    }
    if let fraction = fractionDigits {
      if fraction < 0 || fraction > 8 {
        throw DecodingError.dataCorruptedError(
          forKey: .fractionDigits, in: container,
          debugDescription:
            "Cannot initialize Element because fractionValue \(fraction) must be be in [0..8]")
      }
    }
    if type == .defaultPicker || type == .segmentedPicker {
      if attributeType == nil || (attributeType! != .index && attributeType! != .item) {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not have selected: or selectedItem: in the bind property"
        )
      }
      guard let items = items else {
        throw DecodingError.dataCorruptedError(
          forKey: .type, in: container,
          debugDescription: "Cannot initialize \(type.rawValue) because there are no items")
      }
      if let index = defaultIndex, index < 0 || index >= items.count {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize selected for \(type.rawValue) because it is not in the range of items"
        )
      }
      if autocapitalizationType != nil || defaultBool != nil || defaultNumber != nil
        || container.contains(.disableAutocorrection) || fractionDigits != nil
        || keyboardType != nil || maximumValue != nil || minimumValue != nil || placeholder != nil
      {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it only supports the type, bind, title, items, and selected properties"
        )
      }
    }
    if type == .stepper {
      if attributeType == nil || attributeType! != .number {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not have numberValue: in the bind property"
        )
      }
      if autocapitalizationType != nil || defaultBool != nil || defaultIndex != nil || items != nil
        || container.contains(.disableAutocorrection) || fractionDigits != nil
      {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not support the autocorrectionType, autocapitalizationType, boolValue, items, and selected properties"
        )
      }
    }
    if type == .numberEntry {
      if attributeType == nil || attributeType! != .number {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not have numberValue: in the bind property"
        )
      }
      if autocapitalizationType != nil || defaultBool != nil || defaultIndex != nil || items != nil
        || container.contains(.disableAutocorrection)
      {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not support the autocorrectionType, autocapitalizationType, boolValue, items, selected and fractionDigits properties"
        )
      }
    }
    if type == .multilineText || type == .textEntry {
      if attributeType == nil || attributeType! != .text {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not have textValue: in the bind property"
        )
      }
      if defaultBool != nil || defaultIndex != nil || items != nil || defaultNumber != nil
        || fractionDigits != nil || maximumValue != nil || minimumValue != nil
      {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not support the boolValue, numberValue, selected, items, minimumValue, macimumValue and fractionDigits properties"
        )
      }
    }
    if type == .label {
      if let attributeType = attributeType, attributeType != .id {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it has something besides value: in the bind property"
        )
      }
      if autocapitalizationType != nil || defaultBool != nil || defaultIndex != nil
        || defaultNumber != nil || container.contains(.disableAutocorrection)
        || fractionDigits != nil || items != nil || keyboardType != nil || maximumValue != nil
        || minimumValue != nil || placeholder != nil
      {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it only supports the type, bind, and title properties"
        )
      }
    }
    if type == .switch {
      if attributeType == nil || attributeType! != .bool {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it does not have boolValue: in the bind property"
        )
      }
      if autocapitalizationType != nil || defaultIndex != nil || defaultNumber != nil
        || container.contains(.disableAutocorrection) || fractionDigits != nil || items != nil
        || keyboardType != nil || maximumValue != nil || minimumValue != nil || placeholder != nil
      {
        throw DecodingError.dataCorruptedError(
          forKey: .defaultIndex, in: container,
          debugDescription:
            "Cannot initialize \(type.rawValue) because it only supports the type, bind, title, and boolValue properties"
        )
      }
    }

    self.init(
      attributeType: attributeType,
      attributeName: attributeName,
      autocapitalizationType: autocapitalizationType ?? .none,
      defaultBool: defaultBool,
      defaultIndex: defaultIndex,
      defaultNumber: defaultNumber,
      disableAutocorrection: disableAutocorrection,
      fractionDigits: fractionDigits,
      items: items,
      keyboardType: keyboardType ?? .default,
      maximumValue: maximumValue,
      minimumValue: minimumValue,
      placeholder: placeholder,
      title: title,
      type: type
    )
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(defaultBool.map { $0 ? 1 : 0 }, forKey: .defaultBool)
    try container.encodeIfPresent(defaultIndex, forKey: .defaultIndex)
    try container.encodeIfPresent(defaultNumber, forKey: .defaultNumber)
    try container.encodeIfPresent(fractionDigits, forKey: .fractionDigits)
    try container.encodeIfPresent(items, forKey: .items)
    try container.encodeIfPresent(maximumValue, forKey: .maximumValue)
    try container.encodeIfPresent(minimumValue, forKey: .minimumValue)
    try container.encodeIfPresent(placeholder, forKey: .placeholder)
    try container.encodeIfPresent(title, forKey: .title)
    try container.encodeIfPresent(type, forKey: .type)
    if let attributeType = attributeType, let attributeName = attributeName {
      let bind = attributeType.rawValue + ":" + attributeName
      try container.encode(bind, forKey: .bind)
    }
    try container.encodeIfPresent(autocapitalizationType.text(), forKey: .autocapitalizationType)
    try container.encodeIfPresent(keyboardType.text(), forKey: .keyboardType)
    let disableAC = disableAutocorrection ? "No" : "Default"
    try container.encodeIfPresent(disableAC, forKey: .disableAutocorrection)
  }

}

//MARK: - UIKit

extension UITextAutocapitalizationType {
  init?(text: String) {
    switch text.lowercased() {
    case "allcharacters":
      self = .allCharacters
      break
    case "none":
      self = .none
      break
    case "sentences":
      self = .sentences
    case "words":
      self = .words
      break
    default:
      return nil
    }
  }

  func text() -> String {
    switch self {
    case .allCharacters:
      return "AllCharacters"
    case .none:
      return "None"
    case .sentences:
      return "Sentences"
    case .words:
      return "Words"
    @unknown default:
      return "None"
    }
  }
}

extension UIKeyboardType {
  init?(text: String) {
    switch text.lowercased() {
    case "alphabet", "asciicapable":  // .alphabet is deprecated for .asciiCapable
      self = .asciiCapable
      break
    case "asciicapablenumberpad":
      self = .asciiCapableNumberPad
      break
    case "decimalpad":
      self = .decimalPad
      break
    case "default":
      self = .default
      break
    case "emailaddress":
      self = .emailAddress
      break
    case "namephonepad":
      self = .namePhonePad
      break
    case "numberpad":
      self = .numberPad
      break
    case "numbersandpunctuation":
      self = .numbersAndPunctuation
      break
    case "phonepad":
      self = .phonePad
      break
    case "twitter":
      self = .twitter
      break
    case "url":
      self = .URL
      break
    case "websearch":
      self = .webSearch
      break
    default:
      return nil
    }
  }

  func text() -> String {
    switch self {
    case .asciiCapable:
      return "ASCIICapable"
    case .asciiCapableNumberPad:
      return "ASCIICapableNumberPad"
    case .decimalPad:
      return "DecimalPad"
    case .default:
      return "Default"
    case .emailAddress:
      return "EmailAddress"
    case .namePhonePad:
      return "NamePhonePad"
    case .numberPad:
      return "NumberPad"
    case .numbersAndPunctuation:
      return "NumbersAndPunctuation"
    case .phonePad:
      return "PhonePad"
    case .twitter:
      return "Twitter"
    case .URL:
      return "URL"
    case .webSearch:
      return "WebSearch"
    //case .alphabet:  // Deprecated for .asciiCapable
    //  return "Alphabet"
    @unknown default:
      return "Default"
    }
  }
}

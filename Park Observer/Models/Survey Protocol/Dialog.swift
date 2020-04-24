//
//  Dialog.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Foundation

/// Describes the look and feel feature attribute editor.
///
/// Describes the look and feel of the mission attribute editor.
// MARK: - Dialog
struct Dialog: Codable {
  /// Determines if the sections in this form are grouped.  I.e. there is visual separation
  /// between sections.
  let grouped: Bool?

  /// A list of form elements collected into a single section.
  let sections: [DialogSection]

  /// The text (title) at the top of the editing form.
  let title: String

  enum CodingKeys: String, CodingKey {
    case grouped = "grouped"
    case sections = "sections"
    case title = "title"
  }
}

// MARK: - DialogSection
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

// MARK: - DialogElement
struct DialogElement: Codable {
  /// Determines if and how a text box will auto capitalize the user's typing.
  let autocapitalizationType: DialogElementAutoCapitalization?

  /// Determines if a text box will auto correct (fix spelling) the user's typing.
  let autocorrectionType: DialogElementAutoCorrection?

  /// A special string that encodes the type and attribute name of the data for this element.
  let bind: String?

  /// The default value for a boolean control (0 = false, 1 = true) only used by
  /// QBooleanElement.
  let boolValue: Int?

  /// How many digits will be shown after the decimal point (for QDecimalElement only).
  let fractionDigits: Int?

  /// A list of choices for a picklist type element (QRadioElement or QSegmentedElement).
  let items: [String]?

  /// A unique identifier for this form element; Not used.
  let key: String?

  /// Determines what kind of keyboard will appear when text editing is required.
  let keyboardType: DialogElementKeyboard?

  /// The maximum value allowed in QIntegerElement.
  let maximumValue: Int?

  /// The minimum value allowed in QIntegerElement.
  let minimumValue: Int?

  /// The default number value for a QIntegerElement or QDecimalElement.
  let numberValue: Double?

  /// Sample text to put in a text box to suggest to the user what to enter.
  let placeholder: String?

  /// The zero based index of the intially selected item from the list of items.
  let selected: Int?

  /// The name/prompt that describes the data in this form element.
  let title: String?

  /// One of a well defined set of names for specific form elements.
  let type: DialogElementType

  enum CodingKeys: String, CodingKey {
    case autocapitalizationType = "autocapitalizationType"
    case autocorrectionType = "autocorrectionType"
    case bind = "bind"
    case boolValue = "boolValue"
    case fractionDigits = "fractionDigits"
    case items = "items"
    case key = "key"
    case keyboardType = "keyboardType"
    case maximumValue = "maximumValue"
    case minimumValue = "minimumValue"
    case numberValue = "numberValue"
    case placeholder = "placeholder"
    case selected = "selected"
    case title = "title"
    case type = "type"
  }
}

/// Determines if and how a text box will auto capitalize the user's typing.
///
/// The different choices for fixing capitalization.
enum DialogElementAutoCapitalization: String, Codable {
  case allCharacters = "AllCharacters"
  case none = "None"
  case sentences = "Sentences"
  case words = "Words"
}

/// Determines if a text box will auto correct (fix spelling) the user's typing.
///
/// The different choices for fixing spelling errors.
enum DialogElementAutoCorrection: String, Codable {
  case dialogElementAutoCorrectionDefault = "Default"
  case no = "No"
  case yes = "Yes"
}

/// Determines what kind of keyboard will appear when text editing is required.
///
/// The different choices for on screen keyboards.
enum DialogElementKeyboard: String, Codable {
  case alphabet = "Alphabet"
  case asciiCapable = "ASCIICapable"
  case decimalPad = "DecimalPad"
  case dialogElementKeyboardDefault = "Default"
  case emailAddress = "EmailAddress"
  case namePhonePad = "NamePhonePad"
  case numberPad = "NumberPad"
  case numbersAndPunctuation = "NumbersAndPunctuation"
  case phonePad = "PhonePad"
  case twitter = "Twitter"
  case url = "URL"
}

/// One of a well defined set of names for specific form elements.
///
/// The different kinds of form elements.
enum DialogElementType: String, Codable {
  case qBooleanElement = "QBooleanElement"
  case qDecimalElement = "QDecimalElement"
  case qEntryElement = "QEntryElement"
  case qIntegerElement = "QIntegerElement"
  case qLabelElement = "QLabelElement"
  case qMultilineElement = "QMultilineElement"
  case qRadioElement = "QRadioElement"
  case qSegmentedElement = "QSegmentedElement"
}

//
//  AttributeFormView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/7/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct AttributeFormView: View {
  let form: AttributeFormDefinition
  let showValidation: Bool
  // Use a counter for the state because we want the view to re-render whenever an attribute changes
  @State private var editCount = 0

  var body: some View {
    // Must be embedded in a Navigation view for the picker to work
    // Expects to be embeded in a Form
    ForEach(form.sections) { section in
      Section(
        header: OptionalTextView(section.header),
        footer: OptionalTextView(section.footer)
      ) {
        ForEach(section.elements, id: \.id) { element in
          VStack(alignment: .leading) {
            self.build(element)
            if self.showValidation && self.editCount >= 0 {
              OptionalTextView(element.validationMessage).foregroundColor(.red)
            }
          }
        }
      }
    }
  }

  func build(_ element: FormElement) -> some View {
    Group {
      if element is DoubleElement {
        build(element as! DoubleElement)
      } else if element is IntElement {
        build(element as! IntElement)
      } else if element is LabelElement {
        build(element as! LabelElement)
      } else if element is PickerElement {
        build(element as! PickerElement)
      } else if element is TextElement {
        build(element as! TextElement)
      } else if element is ToggleElement {
        build(element as! ToggleElement)
      } else {
        EmptyView()
      }
    }
  }

  func build(_ e: DoubleElement) -> some View {
    let stringFormat: String = {
      if let digits = e.decimals, digits >= 0, digits < 15 {
        return "%.\(digits)f"
      }
      return "%f"
    }()
    let formatter: NumberFormatter = {
      let formatter = NumberFormatter()
      if let range = e.range {
        formatter.minimum = NSNumber(value: range.lowerBound)
        formatter.maximum = NSNumber(value: range.upperBound)
      }
      if let digits = e.decimals {
        formatter.maximumFractionDigits = digits
      }
      return formatter
    }()

    return HStack {
      OptionalTextView(e.label)
      DoubleEditView(
        n: e.binding, placeholder: e.placeholder, formatter: formatter, stringFormat: stringFormat,
        onLoseFocus: { self.editCount += 1 }
      )
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .keyboardType(e.keyboard)
      .disableAutocorrection(true)
    }
  }

  func build(_ e: IntElement) -> some View {

    let formatter: NumberFormatter = {
      let formatter = NumberFormatter()
      formatter.allowsFloats = false
      if let minimum = e.range.lowerBound {
        formatter.minimum = NSNumber(value: minimum)
      }
      if let maximum = e.range.upperBound {
        formatter.maximum = NSNumber(value: maximum)
      }
      return formatter
    }()

    return
      Group {
        if e.showStepper {
          StepperView(
            n: e.binding, label: e.label, placeholder: e.placeholder, range: e.range,
            formatter: formatter, keyboard: e.keyboard, onChanged: { self.editCount += 1 })
        } else {
          HStack {
            OptionalTextView(e.label)
            IntEditView(
              n: e.binding, placeholder: e.placeholder, formatter: formatter,
              onLoseFocus: { self.editCount += 1 }
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(e.keyboard)
            .disableAutocorrection(true)
          }
        }
      }

  }

  func build(_ e: LabelElement) -> Text {
    return Text(e.label).font(.headline)
  }

  func build(_ e: PickerElement) -> some View {
    Group {
      if e.segmentedStyle {
        OptionalSegmentedPickerView(
          index: e.binding, label: e.label, choices: e.choices, onChanged: { self.editCount += 1 })
      } else {
        OptionalPickerView(
          index: e.binding, label: e.label, choices: e.choices, onChanged: { self.editCount += 1 })
      }
    }
  }

  func build(_ e: TextElement) -> some View {
    Group {
      if e.lines == 1 {
        HStack {
          OptionalTextView(e.label)
          TextField(
            e.placeholder, text: e.binding,
            onEditingChanged: { gotFocus in
              if !gotFocus { self.editCount += 1 }
            }
          )
          .keyboardType(e.keyboard)
          .autocapitalization(e.autoCapitalization)
          .disableAutocorrection(e.disableAutoCorrect)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        }
      } else {
        VStack(alignment: .leading) {
          OptionalTextView(e.label)
          if #available(iOS 14.0, *) {
            TextEditor(text: e.binding)
              .keyboardType(e.keyboard)
              .autocapitalization(e.autoCapitalization)
              .disableAutocorrection(e.disableAutoCorrect)
              .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary, lineWidth: 1))
          } else {
            MultilineTextField(e.placeholder, text: e.binding, onCommit: { self.editCount += 1 })
              .keyboardType(e.keyboard)
              .autocapitalization(e.autoCapitalization)
              .disableAutocorrection(e.disableAutoCorrect)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
        }
      }
    }

  }

  func build(_ e: ToggleElement) -> OptionalToggle {
    OptionalToggle(
      label: e.label, isOn: e.binding, toggleSet: e.binding.wrappedValue != nil,
      onChanged: { self.editCount += 1 })
  }

}

struct AttributeFormView_Previews: PreviewProvider {
  static var previews: some View {
    AttributeFormView(
      form: AttributeFormDefinition(title: "Testing", sections: []),
      showValidation: true)
  }
}

struct OptionalTextView: View {
  let text: String?

  init(_ text: String? = nil) {
    self.text = text
  }

  var body: some View {
    Group {
      if text != nil {
        Text(text!)
      } else {
        EmptyView()
      }
    }
  }

}

struct OptionalPickerView: View {
  @Binding var index: Int
  let label: String?
  let choices: [String]
  let onChanged: () -> Void

  // rebuild view when state changes
  @State private var changed = false {
    didSet {
      onChanged()
    }
  }

  var body: some View {

    // used to alter state and rebuild view when binding changes
    let proxy = Binding<Int>(
      get: { return self.index },
      set: {
        if $0 != self.index {
          self.changed.toggle()
          self.index = $0
        }
      })

    return
      Picker(
        selection: proxy,
        label: HStack {
          Text(label ?? "")
          Spacer()
          if proxy.wrappedValue >= 0 {
            Image(systemName: "xmark.circle.fill")
              .resizable()
              .frame(width: 22, height: 22)
              .padding([.trailing], 11)
              .foregroundColor(.secondary)
              .onTapGesture {
                proxy.wrappedValue = -1
              }
          }
        }
      ) {
        ForEach(choices.indices, id: \.self) {
          Text(self.choices[$0])
        }
      }
  }

}

struct OptionalSegmentedPickerView: View {
  @Binding var index: Int
  let label: String?
  let choices: [String]
  let onChanged: () -> Void

  // rebuild view when state changes
  @State private var changed = false {
    didSet {
      onChanged()
    }
  }

  var body: some View {

    // used to alter state and rebuild view when binding changes
    let proxy = Binding<Int>(
      get: { return self.index },
      set: {
        if $0 != self.index {
          self.changed.toggle()
          self.index = $0
        }
      })

    return VStack(alignment: .leading) {
      OptionalTextView(label)
      HStack {
        Picker("", selection: proxy) {
          ForEach(choices.indices, id: \.self) {
            Text(self.choices[$0])
          }
        }.pickerStyle(SegmentedPickerStyle())
        if proxy.wrappedValue >= 0 {
          Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: 22, height: 22)
            .padding([.leading], 11)
            .foregroundColor(.secondary)
            .onTapGesture {
              proxy.wrappedValue = -1
            }
        }
      }
    }
  }

}

/// An optional tristate Toggle
struct OptionalToggle: View {
  let label: String
  @Binding var isOn: Bool?

  @State var toggleSet: Bool {
    didSet {
      onChanged()
    }
  }
  let onChanged: () -> Void
  @State private var toggleState = false {
    didSet {
      onChanged()
    }
  }

  var body: some View {
    // Intermediate Bindings to manage the view state
    let toggleSet1 = Binding<Bool>(
      get: {
        if self.isOn == nil { return false } else { return true }
      },
      set: {
        //print("Optional Toggle set Set to \($0)")
        if $0 { self.isOn = self.toggleState } else { self.isOn = nil }
        self.toggleSet = $0
      }
    )
    let toggleState1 = Binding<Bool>(
      get: {
        if self.isOn == nil { return false } else { return self.isOn! }
      },
      set: {
        //print("Optional Toggle set State to \($0)")
        self.isOn = $0
        self.toggleSet = true
      }
    )
    //print("Building View")
    return HStack {
      VStack(alignment: .leading) {
        Text(label)
        if !toggleSet1.wrappedValue {
          Text("Value is undefined (not set)").font(.caption).foregroundColor(.secondary)
        }
      }
      Spacer()
      if toggleSet1.wrappedValue {
        Image(systemName: "xmark.circle.fill")
          .resizable()
          .frame(width: 22, height: 22)
          .padding([.trailing], 11)
          .foregroundColor(.secondary)
          .onTapGesture {
            toggleSet1.wrappedValue = false
          }
      }
      Toggle("", isOn: toggleState1).labelsHidden()
    }

  }
}

struct DoubleEditView: View {
  @Binding var n: Double?
  let placeholder: String
  let formatter: NumberFormatter
  let stringFormat: String
  let onLoseFocus: () -> Void

  var numberProxy: Binding<String> {
    Binding<String>(
      get: {
        guard let n = self.n else { return "" }
        return String(format: self.stringFormat, n)
      },
      set: {
        if $0 == "" {
          self.n = nil
        } else if let value = self.formatter.number(from: $0) {
          self.n = value.doubleValue
        }
      })
  }

  // NOTE: onEditingChanged closure is called when the TextField gains or loses focus.
  // The passed boolean is true when gaining focus and false when losing focus.
  // onCommit is called when the return key (virtual or real) is pressed and before the
  // control loses focus.

  var body: some View {
    VStack {
      TextField(
        placeholder, text: numberProxy,
        onEditingChanged: { gotFocus in
          if !gotFocus { self.onLoseFocus() }
        })
    }
  }
}

struct IntEditView: View {
  @Binding var n: Int?
  let placeholder: String
  let formatter: NumberFormatter
  let onLoseFocus: () -> Void

  var numberProxy: Binding<String> {
    Binding<String>(
      get: {
        guard let n = self.n else { return "" }
        return String(n)
      },
      set: {
        if $0 == "" {
          self.n = nil
        } else if let value = self.formatter.number(from: $0) {
          self.n = value.intValue
        }
      }
    )
  }

  var body: some View {
    VStack {
      TextField(
        placeholder, text: numberProxy,
        onEditingChanged: { gotFocus in
          if !gotFocus { self.onLoseFocus() }
        })
    }
  }
}

struct StepperView: View {
  @Binding var n: Int?
  let label: String?
  let placeholder: String
  let range: ClosedRange<Int?>
  let formatter: NumberFormatter
  let keyboard: UIKeyboardType
  let onChanged: () -> Void

  // rebuild view when state changes
  @State private var changed = false {
    didSet {
      onChanged()
    }
  }

  var body: some View {
    // used to alter state and rebuild view when binding changes
    let proxy = Binding<Int?>(
      get: { return self.n },
      set: {
        if $0 != self.n {
          self.changed.toggle()
          self.n = $0
        }
      })
    return HStack {
      OptionalTextView(label)
      IntEditView(n: proxy, placeholder: placeholder, formatter: formatter, onLoseFocus: {})
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(keyboard)
        .disableAutocorrection(true)
      Stepper("", value: proxy, in: range).labelsHidden()

    }

  }
}

/// Strideable requires Comparable which is already satisfied
extension Optional: Comparable where Wrapped == Int {}

/// Add Strideable to Int? so it can be used in a stepper
extension Optional: Strideable where Wrapped == Int {

  public func distance(to other: Wrapped?) -> Int {
    if let other = other {
      if let me = self {
        return other - me
      } else {
        return other - 0
      }
    } else {
      if let me = self {
        return 0 - me
      } else {
        return 0
      }
    }
  }

  public func advanced(by n: Int) -> Wrapped? {
    if let me = self {
      return me + n
    }
    return n
  }

}

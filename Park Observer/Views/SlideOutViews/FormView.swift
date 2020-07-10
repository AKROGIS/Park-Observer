//
//  FormView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 7/7/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct FormView: View {
  let data: FormData

  var body: some View {
    let te1 = ToggleElement(label: "Toggle #1", key: "toggle1", data: data)
    let te2 = ToggleElement(label: "Toggle #2", key: "toggle2", data: data)
    let l1 = LabelElement(label: "Label #1")
    let l2 = LabelElement(label: "Label #2")
    let i1 = IntElement(
      label: nil, placeholder: "Quantity 0..5", showStepper: true, range: 0...5, key: "int1",
      data: data)
    let i2 = IntElement(
      label: "Count", placeholder: "ph", showStepper: false, range: Int(Int32.min)...Int(Int32.max),
      key: "int2", data: data)
    let d1 = DoubleElement(
      label: nil, placeholder: "Temp °C: -40.00..+40.00", range: -40.0...40.0, decimals: 2,
      key: "double1", data: data)
    let d2 = DoubleElement(
      label: "Temp", placeholder: "°F",
      range: -1 * Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude, decimals: nil,
      key: "double2", data: data)
    let tf1 = TextElement(
      label: nil, placeholder: "Enter Text", keyboard: .emailAddress,
      autoCapitalization: .allCharacters, disableAutoCorrect: false, lines: 1, key: "text1",
      data: data)
    let tf2 = TextElement(
      label: "Name:", placeholder: "", keyboard: .default, autoCapitalization: .words,
      disableAutoCorrect: true, lines: 1, key: "text2", data: data)
    let tf3 = TextElement(
      label: nil, placeholder: "Comments", keyboard: .default, autoCapitalization: .none,
      disableAutoCorrect: false, lines: 5, key: "text3", data: data)
    let tf4 = TextElement(
      label: "Comments:", placeholder: "", keyboard: .default, autoCapitalization: .sentences,
      disableAutoCorrect: false, lines: 5, key: "text4", data: data)
    let p1a = PickerElement(
      segmentedStyle: false, label: "Size", choices: ["Small", "Medium", "Large"],
      saveAsText: false, key: "pickerInt1", data: data)
    let p1b = PickerElement(
      segmentedStyle: false, label: "Color", choices: ["Red", "Green", "Blue"], saveAsText: true,
      key: "pickerText1", data: data)
    let p2a = PickerElement(
      segmentedStyle: true, label: "Size", choices: ["Small", "Medium", "Large"], saveAsText: false,
      key: "pickerInt2", data: data)
    let p2b = PickerElement(
      segmentedStyle: true, label: "Color", choices: ["Red", "Green", "Blue"], saveAsText: true,
      key: "pickerText2", data: data)
    let s1 = FormSection(
      header: nil, footer: "foot note", elements: [p2a, p2b, l2, te2, tf2, i2, d2, tf4])
    let s2 = FormSection(
      header: "HEADER", footer: "another footer", elements: [p1a, p1b, te1, l1, tf1, i1, d1, tf3])
    let o = ObservationForm(title: "Title", sections: [s2, s1])

    return NavigationView {
      Form {
        ForEach(o.sections) { section in
          Section(
            header: OptionalTextView(section.header),
            footer: OptionalTextView(section.footer)
          ) {
            ForEach(section.elements, id: \.id) { element in
              self.build(element)
            }
          }
        }
      }
      .navigationBarTitle(Text(o.title))
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
      if let digits = e.decimals, digits > 0, digits < 15 {
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
        n: e.binding, placeholder: e.placeholder, formatter: formatter, stringFormat: stringFormat
      )
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .keyboardType(.numbersAndPunctuation)
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
            formatter: formatter)
        } else {
          HStack {
            OptionalTextView(e.label)
            IntEditView(n: e.binding, placeholder: e.placeholder, formatter: formatter)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .keyboardType(.numbersAndPunctuation)
          }
        }
      }

  }

  func build(_ e: LabelElement) -> Text {
    return Text(e.label).font(.headline)
  }

  //TODO: make nullable
  func build(_ e: PickerElement) -> some View {
    Group {
      if e.segmentedStyle {
        OptionalSegmentedPickerView(index: e.binding, label: e.label, choices: e.choices)
      } else {
        OptionalPickerView(index: e.binding, label: e.label, choices: e.choices)
      }
    }
  }

  func build(_ e: TextElement) -> some View {
    Group {
      if e.lines == 1 {
        HStack {
          OptionalTextView(e.label)
          TextField(e.placeholder, text: e.binding)
            .keyboardType(e.keyboard)
            .autocapitalization(e.autoCapitalization)
            .disableAutocorrection(e.disableAutoCorrect)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
      } else {
        VStack(alignment: .leading) {
          OptionalTextView(e.label)
          //TODO: Replace with a multiline text editor
          // TextField is a single line View (no amount of modifiers will change that.
          // Multiline on ios 14: see https://developer.apple.com/documentation/swiftui/texteditor
          // Multiline on ios 13: wrap UITextView; see https://stackoverflow.com/a/56549250
          TextField(e.placeholder, text: e.binding)
            .keyboardType(e.keyboard)
            .autocapitalization(e.autoCapitalization)
            .disableAutocorrection(e.disableAutoCorrect)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
      }
    }

  }

  func build(_ e: ToggleElement) -> OptionalToggle {
    OptionalToggle(label: e.label, isOn: e.binding)
  }

}

struct FormView_Previews: PreviewProvider {
  static var previews: some View {
    FormView(data: FormData())
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

  // rebuild view when state changes
  @State private var changed = false

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
            Image(systemName: "x.circle.fill")
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
        ForEach(0..<choices.count) {
          Text(self.choices[$0])
        }
      }
  }

}

struct OptionalSegmentedPickerView: View {
  @Binding var index: Int
  let label: String?
  let choices: [String]

  // rebuild view when state changes
  @State private var changed = false

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
          ForEach(0..<choices.count) {
            Text(self.choices[$0])
          }
        }.pickerStyle(SegmentedPickerStyle())
        if proxy.wrappedValue >= 0 {
          Image(systemName: "x.circle.fill")
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

  @State private var toggleState = false
  @State private var toggleSet = false

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
        Image(systemName: "x.circle.fill")
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

  var body: some View {
    VStack {
      TextField(placeholder, text: numberProxy)
    }
  }
}

struct IntEditView: View {
  @Binding var n: Int?
  let placeholder: String
  let formatter: NumberFormatter

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
      TextField(placeholder, text: numberProxy)
    }
  }
}

struct StepperView: View {
  @Binding var n: Int?
  let label: String?
  let placeholder: String
  let range: ClosedRange<Int?>
  let formatter: NumberFormatter

  // rebuild view when state changes
  @State private var changed = false

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
      IntEditView(n: proxy, placeholder: placeholder, formatter: formatter)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.numbersAndPunctuation)
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

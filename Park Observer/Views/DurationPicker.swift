//
//  DurationPicker.swift
//  Park Observer
//
//  From https://stackoverflow.com/a/62238898/542911
//

import SwiftUI

struct DurationPicker: UIViewRepresentable {
  @Binding var duration: TimeInterval

  func makeUIView(context: Context) -> UIDatePicker {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .countDownTimer
    datePicker.addTarget(
      context.coordinator, action: #selector(Coordinator.updateDuration), for: .valueChanged)
    return datePicker
  }

  func updateUIView(_ datePicker: UIDatePicker, context: Context) {
    datePicker.countDownDuration = duration
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    let parent: DurationPicker

    init(_ parent: DurationPicker) {
      self.parent = parent
    }

    @objc func updateDuration(datePicker: UIDatePicker) {
      parent.duration = datePicker.countDownDuration
    }
  }
}

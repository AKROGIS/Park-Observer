//
//  ViewModifiers.swift
//  Park Observer
//
//  Created by Regan Sarwas on 6/16/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import Combine
import SwiftUI

//MARK: - .mapButton

enum MapControlSize: CGFloat, CaseIterable, Hashable, Identifiable {
  case small = 44
  case medium = 66
  case large = 88

  var lineWidth: CGFloat {
    switch self {
    case .small:
      return 3
    case .medium:
      return 4.5
    case .large:
      return 6
    }
  }

  var localizedString: String {
    switch self {
    case .small:
      return NSLocalizedString("Small", comment: "")
    case .medium:
      return NSLocalizedString("Medium", comment: "")
    case .large:
      return NSLocalizedString("Large", comment: "")
    }
  }

  var id: MapControlSize { self }

}

extension View {
  func mapButton(darkMode: Bool, size: MapControlSize) -> some View {
    self.modifier(RoundMapButton(darkMode: darkMode, size: size))
  }

  func wideMapButton(darkMode: Bool, size: MapControlSize) -> some View {
    self.modifier(WideMapButton(darkMode: darkMode, size: size))
  }
}

struct RoundMapButton: ViewModifier {
  let darkMode: Bool
  let size: MapControlSize

  func body(content: Content) -> some View {
    content
      .frame(width: size.rawValue, height: size.rawValue)
      .background(Color(darkMode ? .black : .white).opacity(0.65))
      .clipShape(Circle())
      .overlay(Circle().stroke(Color(darkMode ? .black : .white), lineWidth: size.lineWidth))
  }

}

struct WideMapButton: ViewModifier {
  let darkMode: Bool
  let size: MapControlSize

  func body(content: Content) -> some View {
    content
      .frame(minWidth: size.rawValue, minHeight: size.rawValue, maxHeight: size.rawValue)
      .background(Color(darkMode ? .black : .white).opacity(0.65))
      .clipShape(RoundedRectangle(cornerRadius: size.rawValue / 2))
      .overlay(
        RoundedRectangle(cornerRadius: size.rawValue / 2).stroke(
          Color(darkMode ? .black : .white), lineWidth: size.lineWidth))
  }

}

//MARK: - .keyboardAdaptive

// Thanks to https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/

extension View {
  func keyboardAdaptive() -> some View {
    ModifiedContent(content: self, modifier: KeyboardAdaptive())
  }
}

struct KeyboardAdaptive: ViewModifier {
  @State private var keyboardHeight: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .padding(.bottom, keyboardHeight)
      .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
  }
}

extension Publishers {
  static var keyboardHeight: AnyPublisher<CGFloat, Never> {

    let willShow = NotificationCenter.default.publisher(
      for: UIApplication.keyboardWillShowNotification
    )
    .map { $0.keyboardHeight }

    let willHide = NotificationCenter.default.publisher(
      for: UIApplication.keyboardWillHideNotification
    )
    .map { _ in CGFloat(0) }

    return MergeMany(willShow, willHide).eraseToAnyPublisher()
  }
}

extension Notification {
  var keyboardHeight: CGFloat {
    return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
  }
}

struct ViewModifiers_Previews: PreviewProvider {
  static var previews: some View {
    Image(systemName: "map").font(.headline).mapButton(darkMode: true, size: .medium)
  }
}

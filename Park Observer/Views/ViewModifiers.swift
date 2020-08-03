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

extension View {
  func mapButton(darkMode: Bool) -> some View {
    self.modifier(RoundMapButton(darkMode: darkMode))
  }
  func wideMapButton(darkMode: Bool) -> some View {
    self.modifier(WideMapButton(darkMode: darkMode))
  }
}

struct RoundMapButton: ViewModifier {
  let darkMode: Bool

  func body(content: Content) -> some View {
    content
      .frame(width: 44, height: 44)
      .background(Color(darkMode ? .black : .white).opacity(0.65))
      .clipShape(Circle())
      .overlay(Circle().stroke(Color(darkMode ? .black : .white), lineWidth: 3))
  }

}

struct WideMapButton: ViewModifier {
  let darkMode: Bool

  func body(content: Content) -> some View {
    content
      .frame(height: 44)
      .background(Color(darkMode ? .black : .white).opacity(0.65))
      .clipShape(RoundedRectangle(cornerRadius: 22))
      .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(darkMode ? .black : .white), lineWidth: 3))
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
    Image(systemName: "map").font(.headline).mapButton(darkMode: true)
  }
}

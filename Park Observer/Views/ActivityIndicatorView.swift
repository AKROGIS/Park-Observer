//
//  ActivityIndicatorView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/5/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

// When iOS 14 can be a requirement remove and replace with ProgressView()

import SwiftUI
import UIKit

struct ActivityIndicatorView: UIViewRepresentable {

  @Binding var isAnimating: Bool
  let style: UIActivityIndicatorView.Style

  func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>)
    -> UIActivityIndicatorView
  {
    return UIActivityIndicatorView(style: style)
  }

  func updateUIView(
    _ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>
  ) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
  }

}

struct ActivityIndicatorView_Previews: PreviewProvider {
  static var previews: some View {
    ActivityIndicatorView(isAnimating: .constant(true), style: .medium)
  }
}

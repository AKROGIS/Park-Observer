//
//  SceneDelegate.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This class is responsible for managing the lifecycle of a scene (window) in the application.
/// The name of this class is specified in the Apps's info.plist file in a configuration section which referenced by name
/// in the AppDelegate configure scene method.  This class is created (along with a Scene class) and attached to the
/// scene by the UIApplicationMain(_:_:_:_:) function (implicitly declared by the @UIApplicationMain decorator in
/// AppDelegate). This file is provided with boilerplate code and delegate call stubs by XCode
///
/// The SceneDelegate is actually a WindowSceneDelegate (subclass of SceneDelegate), and it owns the window
/// that all of the scene's views draw in.  It attaches the window to the scene (the scene is fed to the window's init()
/// The SceneDelegate creates the root view (ContentView) and attaches it to the window.

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    let contentView = ContentView()
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started)
    // when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific
    // state information to restore the scene back to its current state.
  }

}

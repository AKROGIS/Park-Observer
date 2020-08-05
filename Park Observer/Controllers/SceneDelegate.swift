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
  let surveyController = SurveyController()

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    let contentView = ContentView().environmentObject(surveyController)
      .environmentObject(surveyController.userSettings)
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
      // Load the map/survey when the scene is created, not every time it becomes active
      surveyController.restoreState()
      surveyController.loadMap()
      surveyController.loadSurvey()
    }
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // For developer testing, remove in production.
    //surveyController.loadMap(name: "Anchorage18")
    //surveyController.loadSurvey(name: "ARCN Bears")
    //surveyController.loadSurvey(name: "DENA Caribou Survey")
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    surveyController.isInBackground = false
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    surveyController.isInBackground = true
  }

}

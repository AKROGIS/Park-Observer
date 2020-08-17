//
//  AppDelegate.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/6/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// This class is responsible for managing the lifecycle of the application.
/// This app delegate maintains no application state (see the Scene Delegate)
///
/// @UIApplicationMain is expanded to a main() function which is the entry point called by the OS to start the app.
/// The default main() calls UIApplicationMain(_:_:_:_:)  with default parameters and the name of this class.
/// UIApplicationMain() instantiates this class and attaches it to the singleton Application() class it also creates.
/// UIApplicationMain() also creates the application's scenes and scene delegates (based on instructions
/// from the app delegate) and then starts the run loop and never returns.  The app delegate and any state it owns
/// will never be deallocated, however scenes may come and go.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Ignore licensing result (Bool). We can run without a license
    _ = LicenseManager.licenseArcGISRuntime()

    // Disable shake to undo. Many users are in bouncy vehicles.
    application.applicationSupportsShakeToEdit = false

    // Set up default map and sample survey on very first launch
    if !FileManager.default.hasSurveyDirectory {
      do {
        try FileManager.default.createSurveyDirectory()
        // This will silently do nothing if the directory exists
      } catch {
        print("Unable to create directory for survey files.\n\(error)")
        return false
      }
      if let sampleURL = Bundle().url(forResource: "Sample", withExtension: "obsprot") {
        if let appFile = try? FileManager.default.addToApp(url: sampleURL) {
          if let newName = try? Survey.create("Sample Survey", from: appFile.name) {
            Defaults.surveyName.write(newName)
          }
        }
      }
      Defaults.mapName.write("Esri Imagery")
    }

    // We are ready to go!
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(
      name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(
    _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running,
    // this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes,
    // as they will not return.
  }

}

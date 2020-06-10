//
//  Survey.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/18/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

/// A Survey is responsible for managing all data associated with a survey.  This includes the configuration
/// data in the SurveyProtocol, the metadata in SurveyInfo, and the CoreData database.
/// A survey cannot be created until there is a representation on disk as a bundle of files.  The bundle can
/// be created by unpacking an archive (FileManager.addToApp(poz_archive), or by the create() class method.
/// Once a survey exists on disk, an in-memory object can be created by calling the load() class method.
/// which asynchronously loads all the files in a survey.  A survey object cannot be initialized directly.
/// The survey object is responsible for persisting saving changes to the metadata and database to disk.
/// The survey object itself is immutable to callers, but it can mutate the metadata in response to
/// user actions, i.e. export.  Of course the database is mutable.

import CoreData

class Survey {

  /// The last path component (without extension) of the folder (bundle) containing the survey files
  let name: String

  /// The in-memory representation of the survey protocol (*.obsprot) file
  let config: SurveyProtocol

  /// The in-memory representation of the survey metadata info.plist file
  private(set) var info: SurveyInfo

  /// The main CoreData context; This context (and the objects it contains) can only be used on the main (UI) thread.
  /// It is backed by a Sqlite3 database on disk.
  let viewContext: NSManagedObjectContext

  private init(name: String, info: SurveyInfo, config: SurveyProtocol, viewContext: NSManagedObjectContext) {
    self.name = name
    self.info = info
    self.config = config
    self.viewContext = viewContext
  }

}

//MARK: - Create/Load

extension Survey {

  enum LoadError: Error {
    case noObjectModel
    case noInfo(error: Error)
    case noDatabase(error: Error)
    case noProtocol(error: Error)
  }

  /// Load a survey async, a Result with a survey or error will be returned to the completion handler
  /// This is the primary (only way in production) to get a survey object
  static func load(_ name: String, completionHandler: @escaping (Result<Survey, LoadError>) -> Void)
  {
    DispatchQueue.global(qos: .userInitiated).async {
      var result: Result<Survey, LoadError>
      do {
        var info = try SurveyInfo(fromURL: FileManager.default.surveyInfoURL(with: name))
        do {
          let skipValidation = info.version == 1  // Skip validation on legacy surveys
          let config = try SurveyProtocol(
            fromURL: FileManager.default.surveyProtocolURL(with: name),
            skipValidation: skipValidation)
          if let mom = config.managedObjectModel {
            let url = info.version == 1
              ? FileManager.default.surveyOldDatabaseURL(with: name)
              : FileManager.default.surveyDatabaseURL(with: name)
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = psc
            do {
              try psc.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: url, options: nil)
              if info.state == .unborn {
                info = info.with(state: .created)
                // Save is optional; we can try again in the save() method
                try? info.write(to: FileManager.default.surveyInfoURL(with: name))
              }
              let survey = Survey(name: name, info: info, config: config, viewContext: context)
              result = .success(survey)
            } catch {
              info = info.with(state: .corrupt)
              try info.write(to: FileManager.default.surveyInfoURL(with: name))
              result = .failure(.noDatabase(error: error))
            }
          } else {
            info = info.with(state: .corrupt)
            try info.write(to: FileManager.default.surveyInfoURL(with: name))
            result = .failure(LoadError.noObjectModel)
          }
        } catch {
          info = info.with(state: .corrupt)
          try info.write(to: FileManager.default.surveyInfoURL(with: name))
          result = .failure(.noProtocol(error: error))
        }
      } catch {
        result = .failure(.noInfo(error: error))
      }
      DispatchQueue.main.async {
        completionHandler(result)
      }
    }
  }

  /// Creates (but does not open) a new survey
  /// It returns the filename of the new survey (may be changed to reflect replacing bad filesystem characters or to avoid a conflict)
  /// Will throw if the file exists, unless conflict is .replace or .keepBoth
  /// May also throw if there are other file system errors;
  /// If it does throw, all intermediate files will be deleted, otherwise the new survey is ready to be loaded
  static func create(
    _ name: String, from protocolFile: String, conflict: ConflictResolution = .fail
  ) throws -> String {
    let newName = try FileManager.default.newSurveyDirectory(
      name.sanitizedFileName, conflict: conflict)
    do {
      let sourceProtocolURL = FileManager.default.protocolURL(with: protocolFile)
      let surveyProtocolURL = FileManager.default.surveyProtocolURL(with: newName)
      try FileManager.default.copyItem(at: sourceProtocolURL, to: surveyProtocolURL)
      let infoURL = FileManager.default.surveyInfoURL(with: newName)
      let info = SurveyInfo(named: name)
      try info.write(to: infoURL)
    } catch {
      try? FileManager.default.deleteSurvey(with: newName)
      throw error
    }
    return newName
  }

}

// MARK: - Instance methods

extension Survey {

  func save() throws {
    if viewContext.hasChanges {
      try viewContext.save()
    }
    info = info.with(modificationDate: Date(), state: .modified)
    try info.write(to: FileManager.default.surveyInfoURL(with: name))
  }

  func setTitle(_ title: String) {
    info = info.with(title: title)
    // This save to disk is optional, so don't try to hard
    try? info.write(to: FileManager.default.surveyInfoURL(with: name))
  }

  // TODO: make private and call in deinit
  func close() {
    if let psc = viewContext.persistentStoreCoordinator {
      for store in psc.persistentStores {
        try? psc.remove(store)
      }
    }
  }

}

//MARK: - Export

extension Survey {

  /// Grabs all objects in a survey database and writes the data to CSV files on a background thread.
  func exportAsCSV(at url: URL, _ completionHandler: @escaping (Error?) -> Void) {
    let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateContext.persistentStoreCoordinator = self.viewContext.persistentStoreCoordinator
    privateContext.perform {
      // This background context cannot use any managed objects from another context/thread,
      // and any objects fetched in this context cannot be passed to another context/thread.
      do {
        let files = try self.csvFiles()
        for fileName in files.keys {
          let fileUrl = url.appendingPathComponent(fileName + ".csv")
          if let fileText = files[fileName] {
            try fileText.write(to: fileUrl, atomically: false, encoding: .utf8)
          }
        }
        DispatchQueue.main.async {
          completionHandler(nil)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler(error)
        }
      }
    }
  }

  func saveToArchive() throws {
    info = info.with(exportDate: Date(), state: .saved)
    try info.write(to: FileManager.default.surveyInfoURL(with: name))

    //TODO: implement
    // Add parameter for conflict strategy (default is replace) and callback.
    // create temp URL (based on info.title)
    // save survey (turn off writing ??)
    // copy survey to temp URL
    // export CSV to temp URL
    // zip up temp URL to temp/title.poz
    // add temp/title.poz to app with conflict strategy
  }

}


// TODO: Goes to SurveyController

//MARK: - Adding Features

// Called by user actions (UI thread), or CoreLocation updates
// Assume for now that CoreLocation updates happen on the UI thread as they also update the map.

//MARK: - Refresh Map

// Grabs all objects in a freshly opened survey to update the map.
// Loading large surveys takes a few seconds, but it is unclear where the bottleneck is.
// This might work best if called on as a background task to create the UI data structures
// Then update the map on the UI thread.

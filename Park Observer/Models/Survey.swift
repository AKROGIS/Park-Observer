//
//  Survey.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/18/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData

/// A Survey is responsible for all interaction with the database
/// It is imutable (of course the database it manages is not)
struct Survey {
  let name: String
  let info: SurveyInfo
  let config: SurveyProtocol
  let viewContext: NSManagedObjectContext
}

//MARK: - Create a survey

extension Survey {

  enum LoadError: Error {
    case noObjectModel
    case noInfo(error: Error)
    case noDatabase(error: Error)
    case noProtocol(error: Error)
  }

  /// Load a survey async, a results with a survey or error will be returned to the completion handler
  /// This is the primary (only way in production) to get a survey object
  static func load(_ name: String, completionHandler: @escaping (Result<Survey, LoadError>) -> Void)
  {
    DispatchQueue.global(qos: .userInitiated).async {
      var result: Result<Survey, LoadError>
      do {
        let info = try SurveyInfo(fromURL: FileManager.default.surveyInfoURL(with: name))
        do {
          let skipValidation = info.codingVersion == 1  // Skip validation on legacy surveys
          let config = try SurveyProtocol(
            fromURL: FileManager.default.surveyProtocolURL(with: name),
            skipValidation: skipValidation)
          if let mom = config.managedObjectModel {
            let url = FileManager.default.surveyDatabaseURL(with: name)
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = psc
            do {
              try psc.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: url, options: nil)
              let survey = Survey(name: name, info: info, config: config, viewContext: context)
              result = .success(survey)
            } catch {
              result = .failure(.noDatabase(error: error))
            }
          } else {
            result = .failure(LoadError.noObjectModel)
          }
        } catch {
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

  func save() throws {
    try viewContext.save()
  }

  func close() {
    if let psc = viewContext.persistentStoreCoordinator {
      for store in psc.persistentStores {
        try? psc.remove(store)
      }
    }
  }

}

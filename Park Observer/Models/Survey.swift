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

}

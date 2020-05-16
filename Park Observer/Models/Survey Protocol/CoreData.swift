//
//  CoreData.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 5/15/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData

//MARK: - Attribute extension for CoreData

extension String {
  // Prefix the user provided attribute and table names to avoid collisions with database reserved words
  // Do not change these definitions; they are required for compatibility with legacy databases
  static let attributePrefix = "A_"

  static let observationPrefix = "O_"
}

extension NSAttributeType {
  init(attributeType: Attribute.AttributeType) {
    switch attributeType {
    case .bool:
      self = .booleanAttributeType
      break
    case .datetime:
      self = .dateAttributeType
      break
    case .decimal:
      self = .decimalAttributeType
      break
    case .double:
      self = .doubleAttributeType
      break
    case .float:
      self = .floatAttributeType
      break
    case .id, .int32:
      self = .integer32AttributeType
      break
    case .int16:
      self = .integer16AttributeType
      break
    case .int64:
      self = .integer64AttributeType
      break
    case .string:
      self = .stringAttributeType
      break
    case .blob:
      self = .binaryDataAttributeType
      break
    }
  }
}

extension Attribute {
  var attributeDescription: NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = .attributePrefix + self.name
    attr.attributeType = NSAttributeType(attributeType: self.type)
    return attr
  }
}

//MARK: - Attribute extension for CoreData

extension ProtocolMission {
  var propertyDescriptions: [NSPropertyDescription]? {
    return self.attributes?.map { $0.attributeDescription }
  }
}

extension Feature {
  var propertyDescriptions: [NSPropertyDescription]? {
    return self.attributes?.map { $0.attributeDescription }
  }
}

extension SurveyProtocol {

  var managedObjectModel: NSManagedObjectModel? {
    // Get the default model -- merge of all models (1) in the main App bundle
    guard let mom = NSManagedObjectModel.mergedModel(from: nil) else {
      return nil
    }
    // Add mission attributes
    if let missionEntity = mom.entitiesByName[.entityNameMissionProperty] {
      if let missionAttributes = self.mission?.propertyDescriptions {
        missionEntity.properties.append(contentsOf: missionAttributes)
      }
    }

    // Add attributes for each feature
    for feature in self.features {
      let entityName = .observationPrefix + feature.name
      guard !mom.entitiesByName.keys.contains(entityName) else { break }
      if let observationEntity = mom.entitiesByName[.entityNameObservation] {
        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = .classNameObservtion
        if let featureAttributes = feature.propertyDescriptions {
          entity.properties.append(contentsOf: featureAttributes)
        }
        observationEntity.subentities.append(entity)
        mom.entities.append(entity)
      }
    }
    return mom
  }
}

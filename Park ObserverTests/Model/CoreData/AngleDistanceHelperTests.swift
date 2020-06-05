//
//  AngleDistanceHelperTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/29/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class AngleDistanceHelperTests: XCTestCase {

  func testNoInputs() {
    // Given:
    let ad = AngleDistanceHelper(config: nil, heading: nil)
    let loc = Location(latitude: 62.0, longitude: -154.0)

    XCTAssertNil(ad.config)
    XCTAssertNil(ad.heading)
    XCTAssertNil(ad.absoluteAngle)
    XCTAssertNil(ad.userAngle)
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    XCTAssertNil(ad.perpendicularMeters)
    XCTAssertNil(ad.featureLocationFromUserLocation(loc))
  }

  // MARK: - Length Tests

  func testInputOnlyMeterDistance() {
    // Given:
    var ad = AngleDistanceHelper(config: nil, heading: nil)
    let loc = Location(latitude: 62.0, longitude: -154.0)

    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    ad.distanceInMeters = 75.0
    XCTAssertNotNil(ad.distanceInMeters)
    if let distance = ad.distanceInMeters {
      XCTAssertEqual(distance, 75.0, accuracy: 0.001)
    }
    // We can convert distances without config or heading
    // default user distance is meters
    XCTAssertNotNil(ad.distanceInUserUnits)
    if let distance = ad.distanceInUserUnits {
      XCTAssertEqual(distance, 75.0, accuracy: 0.001)
    }
    // No Angles
    XCTAssertNil(ad.absoluteAngle)
    XCTAssertNil(ad.userAngle)
    // No angle so no other results
    XCTAssertNil(ad.perpendicularMeters)
    XCTAssertNil(ad.featureLocationFromUserLocation(loc))
  }

  func testInputOnlyUserDistance() {
    // Given:
    var ad = AngleDistanceHelper(config: nil, heading: nil)
    let loc = Location(latitude: 62.0, longitude: -154.0)

    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    ad.distanceInUserUnits = -65.0
    XCTAssertNotNil(ad.distanceInUserUnits)
    if let distance = ad.distanceInUserUnits {
      XCTAssertEqual(distance, -65.0, accuracy: 0.001)
    }
    // We can convert distances without config or heading
    // default user distance is meters
    XCTAssertNotNil(ad.distanceInMeters)
    if let distance = ad.distanceInMeters {
      XCTAssertEqual(distance, -65.0, accuracy: 0.001)
    }
    // No Angles
    XCTAssertNil(ad.absoluteAngle)
    XCTAssertNil(ad.userAngle)
    // No angle so no other results
    XCTAssertNil(ad.perpendicularMeters)
    XCTAssertNil(ad.featureLocationFromUserLocation(loc))
  }

  func testLengthMeters2Meters() {
    // Given:
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "units":"meters"}"#.utf8))

    // When:
    XCTAssertNotNil(config)
    var ad = AngleDistanceHelper(config: config, heading: nil)
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    let meters = 75.0
    ad.distanceInMeters = meters

    // Then:
    XCTAssertNotNil(ad.distanceInUserUnits)
    if let distance = ad.distanceInUserUnits {
      XCTAssertEqual(distance, meters, accuracy: 0.001)
    }

    // When:
    ad.distanceInUserUnits = meters

    // Then:
    XCTAssertNotNil(ad.distanceInMeters)
    if let distance = ad.distanceInMeters {
      XCTAssertEqual(distance, meters, accuracy: 0.001)
    }
  }

  func testLengthFeet2Meters() {
    // Given:
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "units":"feet"}"#.utf8))

    // When:
    XCTAssertNotNil(config)
    var ad = AngleDistanceHelper(config: config, heading: nil)
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    ad.distanceInMeters = 75.0
    let feet = 246.063  // 75 / 0.3048

    // Then:
    XCTAssertNotNil(ad.distanceInUserUnits)
    if let distance = ad.distanceInUserUnits {
      XCTAssertEqual(distance, feet, accuracy: 0.001)
    }

    // When:
    ad.distanceInUserUnits = 35.0
    let meters = 10.668  // 35 * 0.3048

    // Then:
    XCTAssertNotNil(ad.distanceInMeters)
    if let distance = ad.distanceInMeters {
      XCTAssertEqual(distance, meters, accuracy: 0.001)
    }
  }

  func testLengthYards2Meters() {
    // Given:
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "units":"yards"}"#.utf8))

    // When:
    XCTAssertNotNil(config)
    var ad = AngleDistanceHelper(config: config, heading: nil)
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    ad.distanceInMeters = 75.0
    let feet = 82.021  // (75 / 0.3048) / 3

    // Then:
    XCTAssertNotNil(ad.distanceInUserUnits)
    if let distance = ad.distanceInUserUnits {
      XCTAssertEqual(distance, feet, accuracy: 0.001)
    }

    // When:
    ad.distanceInUserUnits = 35.0
    let meters = 32.004  // 35 * 0.3048 * 3

    // Then:
    XCTAssertNotNil(ad.distanceInMeters)
    if let distance = ad.distanceInMeters {
      XCTAssertEqual(distance, meters, accuracy: 0.001)
    }
  }

  // MARK: - Angle Tests

  func testHeadingIsNil() {
    // Given:
    var ad = AngleDistanceHelper(config: nil, heading: nil)
    let loc = Location(latitude: 62.0, longitude: -154.0)

    XCTAssertNil(ad.absoluteAngle)
    XCTAssertNil(ad.userAngle)
    ad.absoluteAngle = 180.0
    XCTAssertNotNil(ad.absoluteAngle)
    if let angle = ad.absoluteAngle {
      XCTAssertEqual(angle, 180.0, accuracy: 0.001)
    }
    // Since heading is nil, we cannot calculate a userAngle
    XCTAssertNil(ad.userAngle)
    // No distance
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    // No distance so no other results
    XCTAssertNil(ad.perpendicularMeters)
    XCTAssertNil(ad.featureLocationFromUserLocation(loc))

    ad.absoluteAngle = nil
    XCTAssertNil(ad.absoluteAngle)
    XCTAssertNil(ad.userAngle)
    ad.userAngle = 180.0
    XCTAssertNotNil(ad.userAngle)
    if let angle = ad.userAngle {
      XCTAssertEqual(angle, 180.0, accuracy: 0.001)
    }
    // Since heading is nil, we cannot calculate an absoluteAngle
    XCTAssertNil(ad.absoluteAngle)
    // No distance
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)
    // No distance so no other results
    XCTAssertNil(ad.perpendicularMeters)
    XCTAssertNil(ad.featureLocationFromUserLocation(loc))

  }

  func testDefaultConfig_Headings_DatabaseAngles() {
    // Given:
    // heading in 0.0 .. 360.0
    // absoluteAngles in 0.0 .. 360.0
    // default config.deadAhead is 0.0  => user angles -180..180 CW
    let absAngles = [-75.0, 0.0, 45.0, 135.0, 225.0, 315.0, 360.0, 362.0]
    let testParams = [
      //( heading, [userAngles])
      (-10.0, [ -65.0,  10.0,  55.0, 145.0, -125.0, -35.0 , 10.0,  12.0]),
      (  0.0, [ -75.0,   0.0,  45.0, 135.0, -135.0, -45.0,   0.0,   2.0]),
      ( 10.0, [ -85.0, -10.0,  35.0, 125.0, -145.0, -55.0, -10.0,  -8.0]),
      (100.0, [-175.0,-100.0, -55.0,  35.0,  125.0,-145.0,-100.0, -98.0]),
      (190.0, [  95.0, 170.0,-145.0, -55.0,   35.0, 125.0, 170.0, 172.0]),
      (280.0, [   5.0,  80.0, 125.0,-145.0,  -55.0,  35.0,  80.0,  82.0]),
      (370.0, [ -85.0, -10.0,  35.0, 125.0, -145.0, -55.0, -10.0,  -8.0])
    ]

    for (heading, userAngles) in testParams {
      var ad = AngleDistanceHelper(config: nil, heading: heading)
      for (i, angle) in absAngles.enumerated() {
        ad.absoluteAngle = angle
        XCTAssertNotNil(ad.userAngle)
        if let user = ad.userAngle {
          XCTAssertEqual(user, userAngles[i], accuracy: 0.001)
        }
      }
    }
  }

  func testDefaultConfig_Headings_UserAngles() {
    // Given:
    // heading in 0.0 .. 360.0
    // default config.deadAhead is 0.0 => user angles -180..180 CW
    let userAngles = [-181.0, -180.0, -135.0, -45.0, 0.0, 45.0, 135.0, 180, 181.0]
    let testParams = [
      //( heading, [absAngles])
      (-10.0, [169.0, 170.0, 215.0, 305.0, 350.0,  35.0, 125.0, 170.0, 171.0]),
      (  0.0, [179.0, 180.0, 225.0, 315.0,   0.0,  45.0, 135.0, 180.0, 181.0]),
      ( 10.0, [189.0, 190.0, 235.0, 325.0,  10.0,  55.0, 145.0, 190.0, 191.0]),
      (100.0, [279.0, 280.0, 325.0,  55.0, 100.0, 145.0, 235.0, 280.0, 281.0]),
      (190.0, [  9.0,  10.0,  55.0, 145.0, 190.0, 235.0, 325.0,  10.0,  11.0]),
      (280.0, [ 99.0, 100.0, 145.0, 235.0, 280.0, 325.0,  55.0, 100.0, 101.0]),
      (370.0, [189.0, 190.0, 235.0, 325.0,  10.0,  55.0, 145.0, 190.0, 191.0])
    ]

    for (heading, absAngles) in testParams {
      var ad = AngleDistanceHelper(config: nil, heading: heading)
      for (i, angle) in userAngles.enumerated() {
        ad.userAngle = angle
        XCTAssertNotNil(ad.absoluteAngle)
        if let abs = ad.absoluteAngle {
          XCTAssertEqual(abs, absAngles[i], accuracy: 0.001)
        }
      }
    }
  }

  func testConfigCCW_Headings_DatabaseAngles() {
    // Given:
    // heading in 0.0 .. 360.0
    // absoluteAngles in 0.0 .. 360.0
    // default config.deadAhead is 0.0  => user angles -180..180 CW
    // When config.direction = CCW  => user angles 180..-180 CW
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "direction": "ccw"}"#.utf8))
    let absAngles = [-75.0, 0.0, 45.0, 135.0, 225.0, 315.0, 360.0, 362.0]
    let testParams = [
      //( heading, [userAngles])
      (-10.0, [ 65.0, -10.0, -55.0,-145.0, 125.0,  35.0, -10.0, -12.0]),
      (  0.0, [ 75.0,   0.0, -45.0,-135.0, 135.0,  45.0,   0.0,  -2.0]),
      ( 10.0, [ 85.0,  10.0, -35.0,-125.0, 145.0,  55.0,  10.0,   8.0]),
      (100.0, [175.0, 100.0,  55.0, -35.0,-125.0, 145.0, 100.0,  98.0]),
      (190.0, [-95.0,-170.0, 145.0,  55.0, -35.0,-125.0,-170.0,-172.0]),
      (280.0, [ -5.0, -80.0,-125.0, 145.0,  55.0, -35.0, -80.0, -82.0]),
      (370.0, [ 85.0,  10.0, -35.0,-125.0, 145.0,  55.0,  10.0,   8.0])
    ]
    XCTAssertNotNil(config)
    for (heading, userAngles) in testParams {
      var ad = AngleDistanceHelper(config: config, heading: heading)
      for (i, angle) in absAngles.enumerated() {
        ad.absoluteAngle = angle
        XCTAssertNotNil(ad.userAngle)
        if let user = ad.userAngle {
          XCTAssertEqual(user, userAngles[i], accuracy: 0.001)
        }
      }
    }
  }

  func testConfigCCW_Headings_UserAngles() {
    // Given:
    // heading in 0.0 .. 360.0
    // default config.deadAhead is 0.0 => user angles -180..180 CW
    // When config.direction = CCW  => user angles 180..-180 CW
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "direction": "ccw"}"#.utf8))
    let userAngles = [-181.0, -180.0, -135.0, -45.0, 0.0, 45.0, 135.0, 180, 181.0]
    let testParams = [
      //( heading, [absAngles])
      ( -10.0, [171.0, 170.0, 125.0,  35.0, 350.0, 305.0, 215.0, 170.0, 169.0]),
      (   0.0, [181.0, 180.0, 135.0,  45.0,   0.0, 315.0, 225.0, 180.0, 179.0]),
      (  10.0, [191.0, 190.0, 145.0,  55.0,  10.0, 325.0, 235.0, 190.0, 189.0]),
      ( 100.0, [281.0, 280.0, 235.0, 145.0, 100.0,  55.0, 325.0, 280.0, 279.0]),
      ( 190.0, [ 11.0,  10.0, 325.0, 235.0, 190.0, 145.0,  55.0,  10.0,   9.0]),
      ( 280.0, [101.0, 100.0,  55.0, 325.0, 280.0, 235.0, 145.0, 100.0,  99.0]),
      ( 370.0, [191.0, 190.0, 145.0, 55.0,   10.0, 325.0, 235.0, 190.0, 189.0]),
    ]
    XCTAssertNotNil(config)
    for (heading, absAngles) in testParams {
      var ad = AngleDistanceHelper(config: config, heading: heading)
      for (i, angle) in userAngles.enumerated() {
        ad.userAngle = angle
        XCTAssertNotNil(ad.absoluteAngle)
        if let abs = ad.absoluteAngle {
          XCTAssertEqual(abs, absAngles[i], accuracy: 0.001)
        }
      }
    }
  }

  func testConfigDeadAhead180_Headings_DatabaseAngles() {
    // Given:
    // heading in 0.0 .. 360.0
    // absoluteAngles in 0.0 .. 360.0
    // default config.deadAhead is 0.0  => user angles -180..180 CW
    // When config.deadAhead is 180.0 => user angles 0..360 CW
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "deadAhead": 180.0}"#.utf8))
    let absAngles = [-75.0, 0.0, 45.0, 135.0, 225.0, 315.0, 360.0, 362.0]
    let testParams = [
      //( heading, [userAngles])
      (-10.0, [ 115.0, 190.0, 235.0, 325.0,  55.0, 145.0, 190.0, 192.0]),
      (  0.0, [ 105.0, 180.0, 225.0, 315.0,  45.0, 135.0, 180.0, 182.0]),
      ( 10.0, [  95.0, 170.0, 215.0, 305.0,  35.0, 125.0, 170.0, 172.0]),
      (100.0, [   5.0,  80.0, 125.0, 215.0, 305.0,  35.0,  80.0,  82.0]),
      (190.0, [ 275.0, 350.0,  35.0, 125.0, 215.0, 305.0, 350.0, 352.0]),
      (280.0, [ 185.0, 260.0, 305.0,  35.0, 125.0, 215.0, 260.0, 262.0]),
      (370.0, [  95.0, 170.0, 215.0, 305.0,  35.0, 125.0, 170.0, 172.0]),
    ]
    XCTAssertNotNil(config)
    for (heading, userAngles) in testParams {
      var ad = AngleDistanceHelper(config: config, heading: heading)
      for (i, angle) in absAngles.enumerated() {
        ad.absoluteAngle = angle
        XCTAssertNotNil(ad.userAngle)
        if let user = ad.userAngle {
          XCTAssertEqual(user, userAngles[i], accuracy: 0.001)
        }
      }
    }
  }

  func testConfigDeadAhead180_Headings_UserAngles() {
    // Given:
    // heading in 0.0 .. 360.0
    // default config.deadAhead is 0.0 => user angles -180..180 CW
    // When config.deadAhead is 180.0 => user angles 0..360 CW
    let config = try? JSONDecoder().decode(
      LocationMethod.self,
      from: Data(#"{"type": "angleDistance", "deadAhead": 180.0}"#.utf8))
    let userAngles = [-1.0, 0.0, 45.0, 135.0, 180.0, 225.0, 315.0, 360, 361.0]
    let testParams = [
      //( heading, [absAngles])
      (-10.0, [169.0, 170.0, 215.0, 305.0, 350.0,  35.0, 125.0, 170.0, 171.0]),
      (  0.0, [179.0, 180.0, 225.0, 315.0,   0.0,  45.0, 135.0, 180.0, 181.0]),
      ( 10.0, [189.0, 190.0, 235.0, 325.0,  10.0,  55.0, 145.0, 190.0, 191.0]),
      (100.0, [279.0, 280.0, 325.0,  55.0, 100.0, 145.0, 235.0, 280.0, 281.0]),
      (190.0, [  9.0,  10.0,  55.0, 145.0, 190.0, 235.0, 325.0,  10.0,  11.0]),
      (280.0, [ 99.0, 100.0, 145.0, 235.0, 280.0, 325.0,  55.0, 100.0, 101.0]),
      (370.0, [189.0, 190.0, 235.0, 325.0,  10.0,  55.0, 145.0, 190.0, 191.0])
    ]
    XCTAssertNotNil(config)
    for (heading, absAngles) in testParams {
      var ad = AngleDistanceHelper(config: config, heading: heading)
      for (i, angle) in userAngles.enumerated() {
        ad.userAngle = angle
        XCTAssertNotNil(ad.absoluteAngle)
        if let abs = ad.absoluteAngle {
          XCTAssertEqual(abs, absAngles[i], accuracy: 0.001)
        }
      }
    }
  }

  // MARK: - Other Properties

  func testPerp_Location_Default() {
    // Given:
    // config.deadAhead = 0, direction = CW, units = meters
    var ad = AngleDistanceHelper(config: nil, heading: 0.0)
    let loc = Location(latitude: 62.0, longitude: -153.0)

    XCTAssertNil(ad.absoluteAngle)
    XCTAssertNil(ad.userAngle)
    XCTAssertNil(ad.distanceInMeters)
    XCTAssertNil(ad.distanceInUserUnits)

    ad.userAngle = 0.0
    ad.distanceInUserUnits = 0.0

    XCTAssertNotNil(ad.absoluteAngle)
    XCTAssertNotNil(ad.distanceInMeters)

    XCTAssertNotNil(ad.perpendicularMeters)
    if let distance = ad.perpendicularMeters {
      XCTAssertEqual(distance, 0.0, accuracy: 0.001)
    }
    let newLocation = ad.featureLocationFromUserLocation(loc)
    XCTAssertNotNil(newLocation)
    if let newLoc = newLocation {
      XCTAssertEqual(newLoc.latitude, loc.latitude, accuracy: 0.000001)
      XCTAssertEqual(newLoc.longitude, loc.longitude, accuracy: 0.000001)
    }
  }

  func testPerp_Location_More() {

    // Testing the AngleDistanceHelper.featureLocationFromUserLocation() functions is tricky,
    // because there is no single answer; it depends on how the earth is modeled, or which
    // projection you are using (and where you are). Park Observer 1 experimented with haversine
    // and several projections before deciding on using a UTM zone projection with esri's software
    // If the implementation changes then the results expected in this test may change (slightly)
    // The results here were tested in ArcGIS.  This test serves to confirm things are working
    // as originally implmented.

    // Given:
    // config.deadAhead = 0, direction = CW, units = meters
    var ad = AngleDistanceHelper(config: nil, heading: 0.0)
    let loc = Location(latitude: 62.0, longitude: -153.0)

    ad.userAngle = 0.0
    ad.distanceInUserUnits = 100.0

    // 100 meters is about 0.000898 degrees latitude (and longitude at the equator)
    XCTAssertNotNil(ad.perpendicularMeters)
    if let distance = ad.perpendicularMeters {
      XCTAssertEqual(distance, 0.0, accuracy: 0.001)
    }
    var newLocation = ad.featureLocationFromUserLocation(loc)
    XCTAssertNotNil(newLocation)
    if let newLoc = newLocation {
      XCTAssertEqual(newLoc.latitude, loc.latitude + 0.0008975, accuracy: 0.000001)
      XCTAssertEqual(newLoc.longitude, loc.longitude, accuracy: 0.000001)
    }

    ad.userAngle = 45.0
    ad.distanceInUserUnits = 100.0

    let perp = 100 / 2.0.squareRoot()
    XCTAssertNotNil(ad.perpendicularMeters)
    if let distance = ad.perpendicularMeters {
      XCTAssertEqual(distance, perp, accuracy: 0.001)
    }
    newLocation = ad.featureLocationFromUserLocation(loc)
    XCTAssertNotNil(newLocation)
    if let newLoc = newLocation {
      XCTAssertEqual(newLoc.latitude, loc.latitude + 0.0006347, accuracy: 0.000001)
      XCTAssertEqual(newLoc.longitude, loc.longitude + 0.0013500, accuracy: 0.000001)
    }

    ad.userAngle = 90.0
    ad.distanceInUserUnits = 100.0
    XCTAssertNotNil(ad.perpendicularMeters)
    if let distance = ad.perpendicularMeters {
      XCTAssertEqual(distance, 100.0, accuracy: 0.001)
    }
    newLocation = ad.featureLocationFromUserLocation(loc)
    XCTAssertNotNil(newLocation)
    if let newLoc = newLocation {
      XCTAssertEqual(newLoc.latitude, loc.latitude, accuracy: 0.000001)
      XCTAssertEqual(newLoc.longitude, loc.longitude + 0.0019089, accuracy: 0.000001)
    }

  }

}

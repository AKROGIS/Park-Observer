//
//  LicenseManagerTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/29/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class LicenseManagerTests: XCTestCase {

  func testLicenseKet() {
    XCTAssertTrue(LicenseManager.licenseArcGISRuntime())
  }

}

//
//  LicenseManager.swift
//  Park Observer
//
//  Created by Regan E. Sarwas on 4/7/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS

struct LicenseManager {

  static func licenseArcGISRuntime() {
    // License key is free for "runtime lite"
    // Available on dashboard of Esri developer site
    do {
      let result = try AGSArcGISRuntimeEnvironment.setLicenseKey(
        "runtimelite,1000,rud9696418117,none,RP5X0H4AH56JXH46C065")
      print("ArcGIS Runtime license request result: \(result.licenseStatus)")
    } catch {
      // Do not abort.
      // Without license app will run with "Developer Mode" watermark on map view
      let nserror = error as NSError
      print("Error licensing ArcGIS Runtime: \(nserror), \(nserror.userInfo)")
    }
  }

}

extension AGSLicenseStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .invalid: return "License is invalid"
    case .expired: return "License has expired"
    case .loginRequired: return "Login required (30 day limit for named user)"
    case .valid: return "License is valid"
    @unknown default: return "** Unexpected/Unknown Status **"
    }
  }
}

//
//  ProtocolDetailsView.swift
//  Park Observer
//
//  Created by Regan Sarwas on 8/13/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import SwiftUI

struct ProtocolDetailsView: View {
  let name: String
  let url: URL
  @State private var jsonObj: Any? = nil
  @State private var errorMessage = "File does not contain a JSON object."

  var body: some View {
    //Assumes it is shown in a Navigation View
    Group {
      if jsonObj is [String: Any] {
        JsonObjectView(dict: jsonObj as! [String: Any])
      } else {
        Text(errorMessage).foregroundColor(.red)
      }
    }
    .navigationBarTitle(name)
    .onAppear {
      do {
        let data = try Data(contentsOf: self.url)
        self.jsonObj = try JSONSerialization.jsonObject(with: data)
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
  }

}

struct JsonView: View {
  let key: String
  let json: Any

  var body: some View {
    Group {
      if json is NSNull {
        JsonItemView(title: key, value: "<NULL>")
      }
      if json is String {
        JsonItemView(title: key, value: json as! String)
      }
      if json is NSNumber {
        if isBoolNumber(num: json as! NSNumber) {
          JsonItemView(title: key, value: json as! NSNumber == 0 ? "False" : "True")
        } else {
          JsonItemView(title: key, value: "\(json as! NSNumber)")
        }
      }
      if json is [Any] {
        NavigationLink(destination: JsonListView(list: json as! [Any]).navigationBarTitle(key)) {
          Text(key)
        }
      }
      if json is [String: Any] {
        NavigationLink(
          destination: JsonObjectView(dict: json as! [String: Any]).navigationBarTitle(key)
        ) {
          Text(key)
        }
      }
    }
  }

  func isBoolNumber(num: NSNumber) -> Bool {
    CFGetTypeID(num) == CFBooleanGetTypeID()
  }

}

struct JsonObjectView: View {
  let dict: [String: Any]

  var body: some View {
    List {
      ForEach(Array(dict.keys.sorted()), id: \.self) { key in
        JsonView(key: key, json: self.dict[key]!)
      }
    }
  }
}

struct JsonListView: View {
  let list: [Any]

  var body: some View {
    List {
      ForEach(list.indices) { i in
        JsonView(key: "Item #\(i+1)", json: self.list[i])
      }
    }
  }
}

struct JsonItemView: View {
  let title: String
  let value: String

  var body: some View {
    VStack(alignment: .leading) {
      Text(title).font(.caption).foregroundColor(.secondary)
      Text(value)
    }
  }
}

struct ProtocolDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    ProtocolDetailsView(name: "protocol1", url: AppFile(type: .surveyProtocol, name: "protocol1").url)
  }
}

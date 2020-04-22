//
//  SettingDictionary.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/15.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//Configure정보를 담을수 있는 데이타형
struct ConfigureData {
  var data: [String: String] = [:]
  
  init() {
    for key in ConfigureType.allCases {
      data[key.rawValue] = ""
    }
  }
}

//BluetoothDevice를 저장하고 사용할때 쓰이는 형태
enum BLEConnectType: String, CaseIterable {
  case scanMode = "scanMode"
  case autoConnectMode = "autoConnectMode"
  case didConnection = "didConnection"
}

//BluetoothDevice를 저장하고 사용할때 쓰이는 형태
enum BluetoothDeviceType: String, CaseIterable {
  case name = "Name"
  case uuid = "UUID"
}

//Configure를 저장하고 사용할때 쓰이는 형태
enum ConfigureType: String, CaseIterable {
  case version = "Version"
  case build = "Build"
  case date = "Date"
  case site = "Site"
  case operate = "Operator"
  case measuringCO = "MeasuringCo"
  case object = "Object"
  case coordinateX = "CoordinateX"
  case coordinateY = "CoordinateY"
  case sensorType = "SensorType"
  case grid = "Grid"
  case comment = "Comment"
}

struct FixSize {
  let version: Int = 10
  let build: Int = 10
  let date: Int = 12
  let site: Int = 51
  let operate: Int = 51
  let measuringCo: Int = 21
  let object: Int = 21
  let coordinateX: Int = 3
  let coordinateY: Int = 3
  let sensorType: Int = 1
  let grid: Int = 4
  let comment: Int = 200
  
  let fileSize = 5512
  let configSize = 512
  
  let maxSizeX = 50
  let maxSizeY = 50
}

enum SensorName: String{
  case Wheel = "Wheel"
  case Rod = "Rod"
}

enum SensorCode: UInt8{
  case Rod = 1
  case Wheel = 2
}


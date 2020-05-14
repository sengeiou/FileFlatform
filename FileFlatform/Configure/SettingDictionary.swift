//
//  SettingDictionary.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/15.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI
  
//Configure정보, 사용자가 입력한 정보를 저장하거나 파일에서 불러왔을때 담음
class ConfigureData: ObservableObject {
  @Published var data: [String: String] = [:]
  @Published var fileName: String = ""
  
  init() {
    for key in ConfigureType.allCases {
      self.data[key.rawValue] = ""
    }
    self.fileName = ""
  }
}

//configure화면이 입력모드인지 수정모드인지
enum ConfigureViewMod: String {
  case input = "input"
  case edit = "edit"
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

//고정 사이즈
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
  
  let fixSizeX = 12
  let fixSizeY = 10
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

//취득 정보를 볼 수 있는 그리드 유형
enum GridViewMod: String {
  case text = "text"
  case gradation = "gradation"
  case contour = "contour"
}

//취득 데이터를 나타내는 그리드에서 각 셀이 갖고 있는 정보
struct CellProperty {
  var acData: String = ""
  var color: Color
  var gradation: [Color] = []
}

func getRGB(acData: Int16)-> Color {
  let value: Double
  let rgb: Color
  if(acData >= -250) {
    value = acData >= 0 ? 0 : Double(acData).magnitude
    rgb = Color.init(red: value/250, green: 250/250, blue: 0/250)
  } else {
    value = acData <= -500 ? 0 : 500 - Double(acData).magnitude
    rgb = Color.init(red: 250/250, green: value/250, blue: 0/250)
  }
  
  return rgb
}

//취득 데이터가 가질 수 있는 최대값 최소값
func setMaxOrMin(value: Int16)-> Int16 {
  if(value > 0) {
    return 0
  } else if(value < -500) {
    return -500
  }
  return value
}
//최소 두군데 에서는 사용해서 그냥 빼둠..ㅠ
//일반적인 전체 파란 배경색
let backgroundColor: UIColor = UIColor(red: 47/255, green: 135/255, blue: 198/255, alpha: 1)
//설정 화면에서 입력창의 배경색
let textFieldBackgroudColor: Color = Color(red: 231/255, green: 235/255, blue: 238/255)
//설정 화면에서 입력창의 글자색
let textFieldForegroundColor: Color = Color(red: 131/255, green: 153/255, blue: 167/255)

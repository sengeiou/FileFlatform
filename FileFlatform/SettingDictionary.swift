//
//  SettingDictionary.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/15.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//Configure정보를 담을수 있는 데이타형
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

//BluetoothDevice를 저장하고 사용할때 쓰이는 형태
enum BLEConnectType: String, CaseIterable {
  case scanMode = "scanMode"
  case autoConnectMode = "autoConnectMode"
  case didConnection = "didConnection"
  case doneConnection = "doneConnection"
}

enum ConfigureViewMod: String {
  case input = "input"
  case edit = "edit"
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

enum GridViewMod: String {
  case text = "text"
  case gradation = "gradation"
  case contour = "contour"
}

struct CellProperty {
  var acData: String = ""
  var color: Color
  var gradation: [Color] = []
}

class ConfigDataForGrid: ObservableObject{
  @Published var cells: [CellProperty]
  @Published var xTextColor: [Color]
  @Published var yTextColor: [Color]
  @Published var selIndex: Int = 0
  @Published var selCellColor: Color
  @Published var configX: Int
  @Published var configY: Int
  @Published var gradationOption: Bool = false //그라데이션, 색상 둘 중에 하나로 표현
  @Published var readMode: Bool = false //파일매니저에서 파일을 볼때인지 아닌지 체크
  
  let fixX: Int
  let fixY: Int
  let devideWidth: CGFloat
  let devideHeight: CGFloat

  let backgroundColor: Color = Color.green
  //let emptyCellColor: Color = Color.gray
  let rowColumnCellColor: Color = Color.orange
  let selRowColumnTextColor: Color = Color.black
  let initRowColumnTextColor: Color = Color.white
  let revealCellColor: Color = Color.white
  let initCellColor: Color = Color.gray
  
  init(configX: Int, configY: Int){
    let fixSize = FixSize()
    
    self.configX = configX
    self.configY = configY
    self.cells = Array(repeating: CellProperty(color: initCellColor), count: configX * configY)
    self.xTextColor = Array(repeating: self.initRowColumnTextColor, count: fixSize.fixSizeX)
    self.yTextColor = Array(repeating: self.initRowColumnTextColor, count: fixSize.fixSizeY)
    self.selCellColor = initCellColor
    self.fixX = fixSize.fixSizeX
    self.fixY = fixSize.fixSizeY
    self.devideWidth = CGFloat(fixSize.fixSizeX + 1)
    self.devideHeight = CGFloat(fixSize.fixSizeY + 1)
  }

  func setRowColumnColor(color: Color) {
    self.xTextColor[self.getCoordinateX()] = color
    self.yTextColor[self.getCoordinateY()] = color
  }
  
  func moveToNext() {
    //전에 선택한 셀 색상 및 x,y 좌표 색상 복구
    self.cells[self.selIndex].color = getRGB(acData: Int16(self.cells[self.selIndex].acData) ?? 0)
    self.setRowColumnColor(color: self.initRowColumnTextColor)
    
    //지금 선택한 셀 인덱스 및 색상 저장
    if (self.lastCheckBeforMove()) {
      self.selIndex = 0
    } else {
      self.selIndex = self.selIndex + 1
    }
    self.selCellColor = self.cells[self.selIndex].color
    
    //선택중인 색상으로 셀 색상, x,y 좌표 색상 변경
    self.cells[self.selIndex].color = self.revealCellColor
    self.setRowColumnColor(color: self.selRowColumnTextColor)
  }
  
  func getCoordinateX()-> Int {
    return self.selIndex % self.configX
  }
  
  func getRealCoordinateX()-> Int {
    return self.selIndex % self.configX + 1
  }
  
  func getCoordinateY()-> Int {
    return self.selIndex / self.configX
  }
  
  func getRealCoordinateY()-> Int {
    return self.selIndex / self.configX + 1
  }
  
  func lastCheckBeforMove()-> Bool {
    //다음 인덱스가 총 크기보다 큰지 아닌지
    if (self.selIndex + 1 >= self.configX * self.configY) {
      return true
    } else {
      return false
    }
  }
  
  func CaculateGradation() {
    for index in 0..<self.cells.count {
      //row에서 첫번째 셀
      if (index % self.configX == 0) {
        getGradationByFixedPreCell(index: index)
      }
      //row에서 마지막 셀
      else if (index % self.configX == self.configX-1) {
        getGradationByFixedNextCell(index: index)
      }
      else { //중간 셀이라면
        getGradationByFixedNextCell(index: index)
        getGradationByFixedPreCell(index: index)
        
      }
    }
  }
  
  func getGradationByFixedPreCell(index: Int) {
    let cell = self.cells[index]
    let cellValue = setMaxOrMin(value: Int16(cell.acData) ?? 0)
    //다음 인덱스가 총 크기보다 작고 && 다음 인덱스가 다음줄이 아니라면
    if(index+1 < self.cells.count && (index % self.configX)+1 < self.configX) {
      let nextCell = self.cells[index+1]
      var nextCellValue = setMaxOrMin(value: Int16(nextCell.acData) ?? 0)
      
      nextCellValue = setNextValueForGradation(value: cellValue, nextValue: nextCellValue)
      
      if(nextCell.acData == String(Int16.max)) {
        self.cells[index].gradation.append(contentsOf: [self.initCellColor, self.initCellColor])
      } else {
        self.cells[index].gradation.append(contentsOf: getGradationColor(value: cellValue, nextValue: nextCellValue))
      }
    } else {
      if(cell.acData == String(Int16.max)) {
        self.cells[index].gradation.append(contentsOf: [self.initCellColor, self.initCellColor])
      } else {
        self.cells[index].gradation.append(contentsOf: getGradationColor(value: cellValue, nextValue: cellValue))
      }
    }
  }
  
  func getGradationByFixedNextCell(index: Int) {
    let cell = self.cells[index]
    let cellValue = setMaxOrMin(value: Int16(cell.acData) ?? 0)
    
    //이전 인덱스가 0보다 작진 않고 && 한줄씩이 아니라면
    if(index-1 >= 0 && self.configX != 1) {
      let preCell = self.cells[index-1]
      var preCellValue = setMaxOrMin(value: Int16(preCell.acData) ?? 0)
      //지금 값과 이전 값의 중간 값을 찾고 그 값을 이전값에 적용
      preCellValue = setPreValueForGradation(value: preCellValue, nextValue: cellValue)
      
      //만약 빈값이면 회색으로 채움
      if(preCell.acData == String(Int16.max)) {
        self.cells[index].gradation.append(contentsOf: [self.initCellColor, self.initCellColor])
      } else {
        
        self.cells[index].gradation.append(contentsOf: getGradationColor(value: preCellValue, nextValue: cellValue))
      }
    }
  }

  func getGradationColor(value: Int16, nextValue: Int16)-> [Color] {
    var colors: [Color] = []
    var value = value
    let sizeCompare: Bool = value > nextValue ? true : false

    let period = (value - nextValue)/10
    colors.append(getRGB(acData: value))
    
    for _ in 0..<10 {
      value = value - period
      
      if sizeCompare {
        if(value < nextValue) {
          colors.append(getRGB(acData: nextValue))
          break
        }
      } else {
        if(value > nextValue) {
          colors.append(getRGB(acData: nextValue))
          break
        }
      }
      colors.append(getRGB(acData: value))
    }
    
    return colors
  }

  func setNextValueForGradation(value: Int16, nextValue: Int16)-> Int16 {
    return nextValue + (value - nextValue)/2
  }

  func setPreValueForGradation(value: Int16, nextValue: Int16)-> Int16 {
    return value - (value - nextValue)/2
  }
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

func setMaxOrMin(value: Int16)-> Int16 {
  if(value > 0) {
    return 0
  } else if(value < -500) {
    return -500
  }
  return value
}

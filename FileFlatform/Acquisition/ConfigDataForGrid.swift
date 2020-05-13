//
//  ConfigDataForGrid.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/11.
//  Copyright © 2020 mcsco. All rights reserved.
//
import SwiftUI

//취득 그리드에서 사용하는 기능들을 모아둠
class ConfigDataForGrid: ObservableObject{
  @Published var cells: [CellProperty] //x * y 개수
  @Published var xTextColor: [Color] //선택한 x좌표의 색상을 변경하기 위해
  @Published var yTextColor: [Color] //선택한 y좌표의 색상을 변경하기 위해
  @Published var selIndex: Int = 0
  @Published var selCellColor: Color
  @Published var configX: Int
  @Published var configY: Int
  @Published var gradationOption: Bool = false //그라데이션, 색상 둘 중에 하나로 표현
  @Published var readMode: Bool = false //파일매니저에서 파일을 볼때인지 아닌지 체크
  
  let fixX: Int //표현할 수 있는 x최대 수
  let fixY: Int //표현할 수 있는 y최대 수
  let devideWidth: CGFloat //화면을 나눌때값 fixX + 1
  let devideHeight: CGFloat //화면을 나눌때값 fixY + 1

  let backgroundColor: Color = Color(red: 137/255, green: 159/255, blue: 173/255)//백그라운드 색상
  //let emptyCellColor: Color = Color.gray
  let rowColumnCellColor: Color = Color(red: 8/255, green: 58/255, blue: 95/255) //x,y 좌표 셀의 색상
  let selRowColumnTextColor: Color = Color.black //선택한 취득 셀의 x, y 좌표셀의 글자 새상
  let initRowColumnTextColor: Color = Color.white //선택하지 않았을때 x, y좌표셀의 글자 색상
  let revealCellColor: Color = Color.white //선택한 취득 셀의 배경색
  let initCellColor: Color = Color.gray // 취득셀의 기본 배경색
  
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

  //선택한 취득셀의 x,y 셀의 텍스트 색상 변경
  func setRowColumnColor(color: Color) {
    self.xTextColor[self.getCoordinateX()] = color
    self.yTextColor[self.getCoordinateY()] = color
  }
  
  //선택중인 셀에서 다음 셀로 넘어감
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
  
  //선택한 셀의 x좌표 얻기
  func getCoordinateX()-> Int {
    return self.selIndex % self.configX
  }
  
  //선택한 셀의 실제 x좌표 얻기 (배열 인덱스 이므로 보여줄땐 +1해야 자연스러움)
  func getRealCoordinateX()-> Int {
    return self.selIndex % self.configX + 1
  }
  
  func getCoordinateY()-> Int {
    return self.selIndex / self.configX
  }
  
  func getRealCoordinateY()-> Int {
    return self.selIndex / self.configX + 1
  }
  
  //마지막 좌표인지 아닌지(세이브 여부를 묻기 위해)
  func lastCheckBeforMove()-> Bool {
    //다음 인덱스가 총 크기보다 큰지 아닌지
    if (self.selIndex + 1 >= self.configX * self.configY) {
      return true
    } else {
      return false
    }
  }
  
  //그라데이션 값 계산
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
  
  //이전 셀을 기준으로 다음 셀의 값이 있다면 그라데이션 얻음
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
  
  //다음 셀을 기준으로 이전 셀의 값이 있다면 그라데이션 얻음
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

  //10등분하여 점진적으로 그라데이션 표현
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

  //현재 셀을 기준으로 다음 셀의 취득값과의 중간값 얻기
  func setNextValueForGradation(value: Int16, nextValue: Int16)-> Int16 {
    return nextValue + (value - nextValue)/2
  }

  //현재 셀을 기준으로 이전 셀의 취득값과의 중간값 얻기
  func setPreValueForGradation(value: Int16, nextValue: Int16)-> Int16 {
    return value - (value - nextValue)/2
  }
}

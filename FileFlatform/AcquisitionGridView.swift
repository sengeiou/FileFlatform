//
//  AcquisitionGridView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/24.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct AcquisitionGridView: View {
  @ObservedObject var config: ConfigDataForGrid
  @State var fontSize: CGFloat = 11.0
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView(Axis.Set.vertical, showsIndicators: true) {
        HStack(alignment: .center, spacing: 0) {
          Text("Y\\X")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width), height: self.reSizeHeight(totalHeight: geometry.size.height))
            .background(self.config.rowColumnCellColor)
            .foregroundColor(self.config.initRowColumnTextColor)
          
          ForEach(0..<self.config.fixX, id: \.self) { index in
            Text("\(index+1)")
              .frame(width: self.reSizeWidth(totalWidth: geometry.size.width)-1.0, height: self.reSizeHeight(totalHeight: geometry.size.height))
              .background(self.config.rowColumnCellColor)
              .padding(.leading, 1)
              .background(self.config.backgroundColor)
              .foregroundColor(self.config.xTextColor[index])
          }
        }
        
        ForEach(0..<self.config.fixY, id: \.self) { indexY in
          HStack(alignment: .center, spacing: 0) {
            Text("\(indexY+1)")
              .frame(width: self.reSizeWidth(totalWidth: geometry.size.width), height: self.reSizeHeight(totalHeight: geometry.size.height)-1)
              .background(self.config.rowColumnCellColor)
              .padding(.top, 1)
              .background(self.config.backgroundColor)
              .foregroundColor(self.config.yTextColor[indexY])
            
            
            if( indexY < self.config.configY ) {
              ForEach(0..<self.config.configX, id: \.self) { indexX in
                Text(self.config.gradationOption ? "" :
                  self.config.cells[self.getIndex(indexX: indexX, indexY: indexY)].acData)
                  .frame(width: self.reSizeWidth(totalWidth: geometry.size.width)-1.0, height: self.reSizeHeight(totalHeight: geometry.size.height)-1.0)
                
                  .background(self.config.gradationOption ?
                    //계산한 [color]값을 배경으로 함
                    LinearGradient(gradient: Gradient(colors: self.config.cells[self.getIndex(indexX: indexX, indexY: indexY)].gradation), startPoint: .leading, endPoint: .trailing)
                    :
                    //해당 셀의 색상 값을 표현(그라데이션이기 때문에 두번 넣음)
                    LinearGradient(gradient: Gradient(colors:[self.config.cells[self.getIndex(indexX: indexX, indexY: indexY)].color, self.config.cells[self.getIndex(indexX: indexX, indexY: indexY)].color]), startPoint: .leading, endPoint: .trailing)
                  )
                  //.background(self.config.cells[self.getIndex(indexX: indexX, indexY: indexY)].color)
                  .padding(.top, 1)
                  .padding(.leading, 1)
                  .background(self.config.backgroundColor)
                  .font(.system(size: self.fontSize))
                  .foregroundColor(Color.black)
                  .onTapGesture {
                    if !self.config.readMode {
                      //전에 선택한 셀 색상 및 x,y 좌표 색상 복구
                      self.config.cells[self.config.selIndex].color = self.config.selCellColor
                      self.config.setRowColumnColor(color: self.config.initRowColumnTextColor)
                      
                      //지금 선택한 셀 인덱스 및 색상 저장
                      self.config.selIndex = self.getIndex(indexX: indexX, indexY: indexY)
                      self.config.selCellColor = self.config.cells[self.config.selIndex].color
                      
                      //선택중인 색상으로 셀 색상, x,y 좌표 색상 변경
                      self.config.cells[self.config.selIndex].color = self.config.revealCellColor
                      self.config.setRowColumnColor(color: self.config.selRowColumnTextColor)
                    }
                }
              }
              
              ForEach(self.config.configX..<self.config.fixX, id: \.self) { indexX in
                Text("x")
                  .frame(width: self.reSizeWidth(totalWidth: geometry.size.width), height: self.reSizeHeight(totalHeight: geometry.size.height))
                  .background(self.config.backgroundColor)
                  .font(.system(size: self.fontSize))
              }
              
            } else {
              ForEach(0..<self.config.fixX, id: \.self) { indexX in
                Text("x")
                  .frame(width: self.reSizeWidth(totalWidth: geometry.size.width), height: self.reSizeHeight(totalHeight: geometry.size.height))
                  .background(self.config.backgroundColor)
                  .font(.system(size: self.fontSize))
              }
            }
          }
        }
      }
    }
    .background(Color.green)
  }
  
  func getIndex(indexX: Int, indexY: Int)-> Int {
    return indexY * self.config.configX + indexX
  }
  
  func reSizeHeight(totalHeight: CGFloat)-> CGFloat {
    let reSize: CGFloat = (totalHeight / self.config.devideHeight).rounded(.toNearestOrEven)
    
    if reSize > self.fontSize * 2.0 {
      return reSize
    } else {
      return self.fontSize * 2.0
    }
  }
  
  func reSizeWidth(totalWidth: CGFloat)-> CGFloat {
    return (totalWidth / self.config.devideWidth).rounded(.toNearestOrEven)
  }
}

struct AcquisitionGridView_Previews: PreviewProvider {
  static var previews: some View {
    AcquisitionGridView(config: ConfigDataForGrid(configX: 5, configY: 5))
  }
}




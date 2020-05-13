//
//  ContourGridView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/30.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//contour 이미지를 포함한 x,y좌표를 보여주는 뷰
struct ContourGridView: View {
  @ObservedObject var config: ConfigDataForGrid
  var fontSize: CGFloat = 11.0
  var contourImage: Image
  

  var body: some View {
    GeometryReader { geometry in
      ScrollView(Axis.Set.vertical, showsIndicators: true) {
        VStack(alignment: .center, spacing: 0) {
          //첫번째 x좌표 줄 그리기
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
          
          //설정한 y좌표까지 이미지를 포함한 줄 그리기
          HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
              ForEach(0..<self.config.configY, id: \.self) { indexY in
                
                Text("\(indexY+1)")
                  .frame(width: self.reSizeWidth(totalWidth: geometry.size.width), height: self.reSizeHeight(totalHeight: geometry.size.height)-1)
                  .background(self.config.rowColumnCellColor)
                  .padding(.top, 1)
                  .background(self.config.backgroundColor)
                  .foregroundColor(self.config.yTextColor[indexY])
              }
            }
            
            self.contourImage
              .resizable()
              .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) * CGFloat(self.config.configX)-1, height: self.reSizeHeight(totalHeight: geometry.size.height) * CGFloat(self.config.configY)-1)
              .padding(.top, 1)
              .padding(.leading, 1)
            
            Text("")
              .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) * CGFloat(self.config.fixX - self.config.configX), height: self.reSizeHeight(totalHeight: geometry.size.height) * CGFloat(self.config.configY))
              .background(self.config.backgroundColor)
          }
          
          //나머지 y좌표 줄 그리기
          HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
              ForEach(self.config.configY..<self.config.fixY, id: \.self) { indexY in
                
                Text("\(indexY+1)")
                  .frame(width: self.reSizeWidth(totalWidth: geometry.size.width), height: self.reSizeHeight(totalHeight: geometry.size.height)-1)
                  .background(self.config.rowColumnCellColor)
                  .padding(.top, 1)
                  .background(self.config.backgroundColor)
                  .foregroundColor(self.config.yTextColor[indexY])
              }
            }
            
            Text("")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) * CGFloat(self.config.fixX), height: self.reSizeHeight(totalHeight: geometry.size.height) * CGFloat(self.config.fixY - self.config.configY))
            .background(self.config.backgroundColor)
          }
        }
      }.padding(2)
    }
    .background(self.config.backgroundColor)
  }
  
  func getIndex(indexX: Int, indexY: Int)-> Int {
    return indexY * self.config.configX + indexX
  }
  
  func reSizeHeight(totalHeight: CGFloat)-> CGFloat {
    let reSize: CGFloat = (totalHeight / self.config.devideHeight).rounded(.toNearestOrEven)
    
    if reSize > self.fontSize * 2.0{
      return reSize
    } else {
      return self.fontSize * 2.0
    }
  } 
  
  func reSizeWidth(totalWidth: CGFloat)-> CGFloat {
    return (totalWidth / self.config.devideWidth).rounded(.toNearestOrEven)
  }
}


struct ContourGridView_Previews: PreviewProvider {
    static var previews: some View {
      ContourGridView(config: ConfigDataForGrid(configX: 5, configY: 5), contourImage: Image(systemName: ""))
    }
}



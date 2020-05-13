//
//  FileConfigureView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/04.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct ConfigureSummaryLine: View {
  var leftTitle: String
  var leftText: String
  var righTitle: String
  var rightText: String
  
  var LeftheadLineWidth: CGFloat = 70 //왼쪽에 위치한 타이틀명 중에 제일 긴 타이틀 길이
  var RightHeadLineWidth: CGFloat = 35 //이런식말고 어떻게 길이를 정해야 하는지 모르겠음
  var cornerRadius: CGFloat = 5
  var textBackgroundColor: Color = Color(red: 20/255, green: 109/255, blue: 175/255)
  var totalHeight: CGFloat = 100
  
  func getHalfWidth(width: CGFloat)-> CGFloat {
    return (width - self.LeftheadLineWidth - self.RightHeadLineWidth - 20) / 2
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack {
        HStack {
          Text("\(self.leftTitle)")
            .lineLimit(1)
            .frame(width: self.RightHeadLineWidth, alignment: .leading)
            .foregroundColor(Color.white)
          Text("\(self.leftText)")
            .lineLimit(1)
            .frame(minWidth: 0, maxWidth: self.getHalfWidth(width: geometry.size.width), alignment: .leading)
            .foregroundColor(Color.white)
        }
        .padding(.all, 2)
        .background(self.textBackgroundColor)
        .cornerRadius(self.cornerRadius)
        
        
        HStack {
          Text("\(self.righTitle)")
            .frame(minWidth: 0, maxWidth: self.LeftheadLineWidth, alignment: .leading)
            .foregroundColor(Color.white)
          Text("\(self.rightText)")
            .lineLimit(1)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.white)
        }
        .padding(.all, 2)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(self.textBackgroundColor)
        .cornerRadius(self.cornerRadius)
      }
    }
  }
}

//cori파일 요약 정보표
struct ConfigureSummaryView: View {
  @ObservedObject var configData: ConfigureData = ConfigureData()
  var LeftheadLineWidth: CGFloat = 70 //왼쪽에 위치한 타이틀명 중에 제일 긴 타이틀 길이
  var RightHeadLineWidth: CGFloat = 35 //이런식말고 어떻게 길이를 정해야 하는지 모르겠음
  var cornerRadius: CGFloat = 5
  var textBackgroundColor: Color = Color(red: 20/255, green: 109/255, blue: 175/255)
  var totalHeight: CGFloat = 110
  
  func getHalfWidth(width: CGFloat)-> CGFloat {
    return (width - self.LeftheadLineWidth - self.RightHeadLineWidth - 20) / 2
  }
  
  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      ConfigureSummaryLine(leftTitle: "File", leftText: self.configData.fileName, righTitle: ConfigureType.date.rawValue, rightText: self.configData.data[ConfigureType.date.rawValue, default: ""])
      
      ConfigureSummaryLine(leftTitle: ConfigureType.site.rawValue, leftText: self.configData.data[ConfigureType.site.rawValue, default: ""], righTitle: ConfigureType.operate.rawValue, rightText: self.configData.data[ConfigureType.operate.rawValue, default: ""])
      
      ConfigureSummaryLine(leftTitle: "CO.", leftText: self.configData.data[ConfigureType.measuringCO.rawValue, default: ""], righTitle: ConfigureType.object.rawValue, rightText: self.configData.data[ConfigureType.object.rawValue, default: ""])
      
      ConfigureSummaryLine(leftTitle: ConfigureType.grid.rawValue, leftText: self.configData.data[ConfigureType.grid.rawValue, default: ""], righTitle: "Sensor", rightText: self.configData.data[ConfigureType.sensorType.rawValue, default: ""])
    }
    .padding([.leading, .trailing], 5)
    .padding(.bottom, 4)
    .background(Color(backgroundColor))
    .frame(height: self.totalHeight)
  }
}

struct ConfigureSummaryView_Previews: PreviewProvider {
  static var previews: some View {
    ConfigureSummaryView()
  }
}

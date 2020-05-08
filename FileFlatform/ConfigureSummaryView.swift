//
//  FileConfigureView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/04.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct ConfigureSummaryView: View {
  @ObservedObject var configData: ConfigureData = ConfigureData()
  var LeftheadLineWidth: CGFloat = 70
  var RightHeadLineWidth: CGFloat = 35
  var cornerRadius: CGFloat = 5
  var backgroundColor: Color = Color.blue
  var totalHeight: CGFloat = 100
  
  func getHalfWidth(width: CGFloat)-> CGFloat {
    return (width - self.LeftheadLineWidth - self.RightHeadLineWidth - 20) / 2
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 2) {
        HStack {
          HStack {
            Text("File")
              .lineLimit(1)
              .frame(width: self.RightHeadLineWidth, alignment: .leading)
            Text("\(self.configData.fileName)")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: self.getHalfWidth(width: geometry.size.width), alignment: .leading)
          }
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
          
          
          HStack {
            Text("\(ConfigureType.date.rawValue)")
              .frame(minWidth: 0, maxWidth: self.LeftheadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.date.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
        }
        
        HStack {
          HStack {
            Text("\(ConfigureType.site.rawValue)")
              .lineLimit(1)
              .frame(width: self.RightHeadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.site.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: self.getHalfWidth(width: geometry.size.width), alignment: .leading)
          }
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
          
          
          HStack {
            Text("\(ConfigureType.operate.rawValue)")
              .frame(minWidth: 0, maxWidth: self.LeftheadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.operate.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
        }
        
        HStack {
          HStack {
            Text("CO.")
              .lineLimit(1)
              .frame(width: self.RightHeadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.measuringCO.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: self.getHalfWidth(width: geometry.size.width), alignment: .leading)
          }
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
          
          
          HStack {
            Text("\(ConfigureType.object.rawValue)")
              .frame(minWidth: 0, maxWidth: self.LeftheadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.object.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
        }
        
        HStack {
          HStack {
            Text("\(ConfigureType.grid.rawValue)")
              .lineLimit(1)
              .frame(width: self.RightHeadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.grid.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: self.getHalfWidth(width: geometry.size.width), alignment: .leading)
          }
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
          
          
          HStack {
            Text("Sensor")
              .frame(minWidth: 0, maxWidth: self.LeftheadLineWidth, alignment: .leading)
            Text("\(self.configData.data[ConfigureType.sensorType.rawValue] ?? "")")
              .lineLimit(1)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          .background(self.backgroundColor)
          .cornerRadius(self.cornerRadius)
        }
      }
    }
    .frame(height: self.totalHeight)
  }
}

struct ConfigureSummaryView_Previews: PreviewProvider {
  static var previews: some View {
    ConfigureSummaryView()
  }
}

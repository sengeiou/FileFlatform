//
//  ContourView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/30.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

private var fContourXScale: Float = 0.0
private var fContourYScale: Float = 0.0

private var config_x_size: Int = 5
private var config_y_size: Int = 5

private var rectContour: CGRect = CGRect(x: 0, y: 0, width: 150, height: 150)
private var contourPath: [ContourPath] = []

struct ContourPath {
  var path: Path
  var color: Color
}

struct ContourView: View {
    @State var path: [ContourPath]
    @State var width: CGFloat
    @State var hegiht: CGFloat
    var body: some View {
      ZStack {
        GeometryReader { geometry in
          ForEach(self.path.indices, id: \.self){ index in
            self.path[index].path
              .fill(self.path[index].color)
              .fixedSize(horizontal: true, vertical: true)
          }
        }.frame(width: width, height: hegiht, alignment: .top)
      }
    }
}

struct ContourView_Previews: PreviewProvider {
    static var previews: some View {
        ContourView(path: [], width: 200, hegiht: 200)
    }
}

func fillContourColor(level: Int, num: Int, point_x: Array<Double>, point_y: Array<Double>){
  var level: Int = level
  var color: Color = Color.red
  var path: Path = Path()
  var pt: Array<SPoint> = Array(repeating: SPoint(x: 0, y: 0), count: 500)
  
  if(level < m_sMinLevel-1) {level += 1}
  switch (level) {
  case 0 : color = Color(red: 250/250, green: 76/250, blue: 0/250)// 빠름 : 빨간색  m_nLevel 0
  case 1 : color = Color(red: 250/250, green: 112/250, blue: 0/250)
  case 2 : color = Color(red: 250/250, green: 154/250, blue: 0/250)
  case 3 : color = Color(red: 250/250, green: 200/250, blue: 0/250)
  case 4 : color = Color(red: 250/250, green: 240/250, blue: 0/250)
  case 5 : color = Color(red: 214/250, green: 250/250, blue: 0/250)
  case 6 : color = Color(red: 170/250, green: 250/250, blue: 0/250)
  case 7 : color = Color(red: 126/250, green: 250/250, blue: 0/250)
  case 8 : color = Color(red: 88/250, green: 250/250, blue: 0/250) 
  case 9 : color = Color(red: 38/250, green: 250/250, blue: 0/250)
  case 10 : color = Color(red: 0/250, green: 250/250, blue: 0/250)
  default:
    break
  }
  
  for i in 0 ..< num {
    pt[i].x = ((point_y[i]-0.6) * Double(fContourXScale))
    pt[i].y = ((point_x[i]-0.6) * Double(fContourYScale))
  }
  
  if(pt[0].x == 0 && pt[num-1].y == 0)
  {
    pt[num-1].x = Double(rectContour.midX)
    pt[num-1].y = Double(rectContour.maxY)
  }
  else if(pt[0].y == 0 && pt[num-1].x >= Double(rectContour.maxX-1))
  {
    pt[num-1].x = Double(rectContour.maxX)
    pt[num-1].y = Double(rectContour.maxY)
  }
  else if(pt[0].x == Double(rectContour.minX) && pt[num-1].y == Double(rectContour.minY))
  {
    pt[num-1].x = Double(rectContour.minX)
    pt[num-1].y = Double(rectContour.minY)
  }
  else if(pt[0].y == Double(rectContour.minY) && pt[num-1].x >= Double(rectContour.maxX-1))
  {
    pt[num-1].x = Double(rectContour.maxX)
    pt[num-1].y = Double(rectContour.minY)
  }
  else if(pt[0].x >= Double(rectContour.maxX-1) && pt[num-1].y == Double(rectContour.minY))  //8  추가 부분 8~6
  {
    pt[num-1].x = Double(rectContour.maxX)
    pt[num-1].y = Double(rectContour.minY)
  }
  else if(pt[0].y == 0 && pt[num-1].x == 0) //2
  {
    pt[num-1].x = Double(rectContour.minX)
    pt[num-1].y = Double(rectContour.maxY)
  }
  else if(pt[0].y == Double(rectContour.minY) && pt[num-1].x == 0)  //4
  {
    pt[num-1].x = Double(rectContour.minX)
    pt[num-1].y = Double(rectContour.minY)
  }
  else if(pt[0].x >= Double(rectContour.maxX-1) && pt[num-1].y == 0)  //6
  {
    pt[num-1].x = Double(rectContour.maxX)
    pt[num-1].y = Double(rectContour.maxY)
  }
  else if(pt[0].x == Double(rectContour.minX) && pt[num-1].x >= Double(rectContour.maxX-1))
  {
    if(pt[0].y < Double(rectContour.height / 2))
    {
      pt[num-1].x = Double(rectContour.maxX)
      pt[num-1].y = Double(rectContour.maxY)
      
      pt[num].x = Double(rectContour.minX)
      pt[num].y = Double(rectContour.maxY)
    }
    else
    {
      pt[num-1].x = Double(rectContour.maxX)
      pt[num-1].y = Double(rectContour.minY)
      
      pt[num].x = Double(rectContour.minX)
      pt[num].y = Double(rectContour.minY)
    }
  }
  
  for i in 0 ..< num {
    if(i == 0) {
      path.move(to: CGPoint(x: pt[i].x, y: pt[i].y))
    }
    else {
      path.addLine(to: CGPoint(x: pt[i].x, y: pt[i].y))
    }
    
  }
  contourPath.append(ContourPath(path: path, color: color))
}

func getContourPath(width: CGFloat, height: CGFloat, configX: Int, configY: Int, acData: Array<String>)-> [ContourPath] {
  m_sMinLevel = 99
  config_x_size = configX
  config_y_size = configY
  rectContour = CGRect(x: 0, y: 0, width: width, height: height)
  fContourXScale = Float(rectContour.width / CGFloat(config_x_size))
  fContourYScale = Float(rectContour.height / CGFloat(config_y_size))
  fContourXScale = fContourXScale * 1.05 //해당 배수정도 확대해야 외곽표현이 자연스러움
  fContourYScale = fContourYScale * 1.05
  contourPath = []

  let contours = Contours( x_size: config_x_size, y_size: config_y_size)

  contours.drawContour(ac_datas: acData)
  
  return contourPath
}

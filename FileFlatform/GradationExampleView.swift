//
//  GradationExampleView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/04.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct GradationExampleView: View {
  let backgroundColor: Color = Color.black
  let fontSize: CGFloat = 13
  
  var body: some View {
    GeometryReader{ geometry in
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text("-500")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) - 1)
            .background(Color(red: 250/250, green: 0/250, blue: 0/250))
            .padding(.leading, 1)
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-450")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width))
            .background(Color(red: 250/250, green: 50/250, blue: 0/250))
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-400")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width))
            .background(Color(red: 250/250, green: 100/250, blue: 0/250))
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-350")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) - 1)
            .background(Color(red: 250/250, green: 150/250, blue: 0/250))
            .padding(.leading, 1)
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-300")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width))
            .background(Color(red: 250/250, green: 200/250, blue: 0/250))
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-250")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width))
            .background(Color(red: 250/250, green: 250/250, blue: 0/250))
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-200")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) - 1)
            .background(Color(red: 200/250, green: 250/250, blue: 0/250))
            .padding(.leading, 1)
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-150")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width))
            .background(Color(red: 150/250, green: 250/250, blue: 0/250))
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-100")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width))
            .background(Color(red: 100/250, green: 250/250, blue: 0/250))
            .padding(.top, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
          Text("-50")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) - 1)
            .background(Color(red: 50/250, green: 250/250, blue: 0/250))
            .padding(.top, 1)
            .padding(.trailing, 1)
            .background(self.backgroundColor)
            .font(.system(size: self.fontSize))
            .foregroundColor(Color.black)
        }
        
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text("BAD")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) * 3 - 1)
            .background(
              LinearGradient(gradient: Gradient(colors: [Color(red: 250/250, green: 0/250, blue: 0/250), Color(red: 250/250, green: 100/250, blue: 0/250)]), startPoint: .leading, endPoint: .trailing))
            .padding(.leading, 1)
            .padding(.top, 1)
            .padding(.bottom, 1)
            .background(self.backgroundColor)
            .foregroundColor(Color.black)
          
          Text("UNDIFINED")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) * 3 - 1)
            .background(
              LinearGradient(gradient: Gradient(colors: [Color(red: 250/250, green: 100/250, blue: 0/250), Color(red: 250/250, green: 250/250, blue: 0/250)]), startPoint: .leading, endPoint: .trailing))
            .padding(.leading, 1)
            .padding(.top, 1)
            .padding(.bottom, 1)
            .background(self.backgroundColor)
            .foregroundColor(Color.black)
          
          Text("GOOD")
            .frame(width: self.reSizeWidth(totalWidth: geometry.size.width) * 4 - 2)
            .background(
              LinearGradient(gradient: Gradient(colors: [Color(red: 200/250, green: 250/250, blue: 0/250), Color(red: 50/250, green: 250/250, blue: 0/250)]), startPoint: .leading, endPoint: .trailing))
            .padding(.all, 1)
            .background(self.backgroundColor)
            .foregroundColor(Color.black)
        }
      }
    }
    .frame(height: 40)
  }
  
  func reSizeWidth(totalWidth: CGFloat)-> CGFloat {
    let reSize: CGFloat = (totalWidth / 10).rounded(.toNearestOrEven)
    
    return reSize
  }
}

struct GradationExampleView_Previews: PreviewProvider {
  static var previews: some View {
    GradationExampleView()
  }
}

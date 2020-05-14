//
//  UnderButtonView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/07.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//하단에 위치한 메인 버튼
struct UnderButtonView: View {
  private var title: String = ""
  private var clickEvent: () -> Void
  
  init(title: String, clickEvent: @escaping () -> Void) {
    self.title = title
    self.clickEvent = clickEvent
  }
  
  let bacgroudColor: UIColor = UIColor(red: 111/255, green: 109/255, blue: 110/255, alpha: 1)
  let buttonColor: UIColor = UIColor(red: 248/255, green: 108/255, blue: 47/255, alpha: 1)
  
  var body: some View {
    GeometryReader{ geometry in
      ZStack {
        Rectangle()
          .frame(width: geometry.size.width, height: 50, alignment: .center)
          .foregroundColor(Color(self.bacgroudColor))
          .cornerRadius(radius: 10, corners: .topLeft)
          .cornerRadius(radius: 10, corners: .topRight)
        
        Button(action: {self.clickEvent()}, label: {
          Text("\(self.title)")
            .frame(width: geometry.size.width-10, height: 40, alignment: .center)
            .background(Color(self.buttonColor))
            .foregroundColor(Color.white)
            .cornerRadius(20)
        })
      }.background(Color.white)
    }
    .frame(height: 50)
  }
}

struct UnderButtonView_Previews: PreviewProvider {
  static var previews: some View {
    UnderButtonView(title: "", clickEvent: {})
  }
}

struct MainButtonView: View {
  let buttonBackgroundColor: Color = Color(red: 28/255, green: 125/255, blue: 197/255)
  var title: String
  var image: String
  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .center, spacing: 0){
        Image("\(self.image)")
          .resizable()
          .frame(width: 25, height: 25)
          .padding(.leading, 10)
          .foregroundColor(Color.white)
        Text("\(self.title)")
          .frame(width: geometry.size.width * 0.6 - 40, alignment: .center)
          .foregroundColor(Color.white)
      }
      .frame(width: geometry.size.width * 0.6, height: 50)
      .background(self.buttonBackgroundColor)
      .cornerRadius(10)
    }
  }
}

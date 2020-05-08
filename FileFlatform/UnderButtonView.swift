//
//  UnderButtonView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/07.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct UnderButtonView: View {
  private var title: String = ""
  private var clickEvent: () -> Void
  
  init(title: String, clickEvent: @escaping () -> Void) {
    self.title = title
    self.clickEvent = clickEvent
  }
  
  var body: some View {
    GeometryReader{ geometry in
      ZStack {
        Rectangle()
          .frame(width: geometry.size.width, height: 50, alignment: .center)
          .foregroundColor(Color.purple)
          .cornerRadius(radius: 10, corners: .topLeft)
          .cornerRadius(radius: 10, corners: .topRight)
        
        Button(action: {self.clickEvent()}, label: {
          Text("\(self.title)")
            .frame(width: geometry.size.width-10, height: 40, alignment: .center)
            .background(Color.orange)
            .cornerRadius(20)
        })
      }
    }
    .frame(height: 50)
  }
}

struct UnderButtonView_Previews: PreviewProvider {
  static var previews: some View {
    UnderButtonView(title: "", clickEvent: {})
  }
}

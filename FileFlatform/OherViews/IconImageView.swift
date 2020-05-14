//
//  IconImageView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/13.
//  Copyright © 2020 mcsco. All rights reserved.
//
import SwiftUI

struct IconImageView: View {
  var imageName: String
  
  var body: some View {
    ZStack{
      Image("\(self.imageName)")
        .resizable()
        .frame(width: 18, height: 18)
        .background(Color(backgroundColor))
        .foregroundColor(Color.white)
    }.frame(width: 30, height: 30, alignment: .center)
  }
}

//
//  AlertViews.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/11.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//뷰 갱신이 겹치면 먹통이 되는 현상이 있어 사용하면 안될듯..

////버튼이 없는 알림 뷰
//struct TextAlert<Presenting>: View where Presenting: View {
//  @Binding var isShowing: Bool
//  let presenting: Presenting
//  @Binding var text: String
//
//  var body: some View {
//    GeometryReader{ geometry in
//      ZStack {
//        self.presenting
//          .background(self.isShowing ? Color.black : Color.clear)
//          .opacity(self.isShowing ? 0.5 : 1)
//          .disabled(self.isShowing)
//          .onTapGesture { self.isShowing = false }
//
//
//        VStack(alignment: .center, spacing: 1) {
//          Text(self.text)
//            .foregroundColor(Color.black)
//            .padding(.all, 5)
//        }
//        .background(Color.white)
//        .opacity(self.isShowing ? 1 : 0)
//        .cornerRadius(10)
//      }
//    }
//  }
//}

//cori about dialog
struct AboutAlert<Presenting>: View where Presenting: View {
  @Binding var isShowing: Bool
  let version: String = "CORI.1.00"
  let build: String = "May152010"
  let presenting: Presenting
  let title: String = "CORI Information"
  
  var body: some View {
    GeometryReader{ geometry in
      ZStack {
        self.presenting
          .background(self.isShowing ? Color.black : Color.clear)
          .opacity(self.isShowing ? 0.5 : 1)
          .disabled(self.isShowing)
          .onTapGesture { self.isShowing = false }
        
        VStack(alignment: .center, spacing: 1) {
          Text(self.title)
            .foregroundColor(Color.black)
            .padding(.all, 5)
          Image("about")
            .resizable()
            .frame(width: 300, height: 150, alignment: .center)
          Text("Version : \(self.version)")
            .foregroundColor(Color.black)
          Text("Build : \(self.build)")
            .foregroundColor(Color.black)
        }
        .frame(width: 300)
        .background(Color.white)
        .opacity(self.isShowing ? 1 : 0)
        .cornerRadius(10)
      }
    }
  }
}

////입력 뷰
//struct TextFieldAlert<Presenting>: View where Presenting: View {
//  @EnvironmentObject var keyboard: KeyboardResponder
//  @Binding var isShowing: Bool
//  let presenting: Presenting
//  @Binding var inputText: String
//  @Binding var title: String
//  var inputComplete: () -> Void
//
//  var body: some View {
//    GeometryReader{ geometry in
//      ZStack {
//        self.presenting
//          .background(self.isShowing ? Color.black : Color.clear)
//          .opacity(self.isShowing ? 0.5 : 1)
//          .disabled(self.isShowing)
//          .onTapGesture { self.isShowing = false }
//
//
//        VStack(alignment: .center, spacing: 1) {
//          TextField(self.title, text: self.$inputText)
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            //.foregroundColor(Color.black)
//            .padding()
//          Button(action: {
//            self.inputComplete()
//            self.isShowing = false
//          }, label: {
//            Text("Ok")
//
//          })
//        }
//        .frame(width: geometry.size.width * 0.7)
//        .background(Color.primary)
//        .opacity(self.isShowing ? 1 : 0)
//        .cornerRadius(10)
//        .padding(.bottom, self.keyboard.currentHeight)
//        .animation(.easeOut(duration: 0.16))
//      }
//    }
//  }
//}


extension View {
  func aboutAlert(isShowing: Binding<Bool>) -> some View {
    AboutAlert(isShowing: isShowing,
               presenting: self)
  }
  
//  func textAlert(isShowing: Binding<Bool>, text: Binding<String>) -> some View {
//    TextAlert(isShowing: isShowing,
//              presenting: self, text: text)
//  }
//
//  func textFieldAlert(isShowing: Binding<Bool>, title: Binding<String>, inputText: Binding<String>, inputComplete: @escaping () -> Void) -> some View {
//    TextFieldAlert(isShowing: isShowing,
//                   presenting: self, inputText: inputText, title: title, inputComplete: inputComplete)
//  }
}


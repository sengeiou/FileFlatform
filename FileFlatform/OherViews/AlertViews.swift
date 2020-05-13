//
//  AlertViews.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/11.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//버튼이 없는 알림 뷰
struct TextAlert<Presenting>: View where Presenting: View {
  @Binding var isShowing: Bool
  let presenting: Presenting
  @Binding var text: String
  
  var body: some View {
    GeometryReader{ geometry in
      ZStack {
        self.presenting
          .background(self.isShowing ? Color.black : Color.clear)
          .opacity(self.isShowing ? 0.5 : 1)
          .disabled(self.isShowing)
          .onTapGesture { self.isShowing = false }
        
        
        VStack(alignment: .center, spacing: 1) {
        Text(self.text)
          .foregroundColor(Color.black)
          .padding(.all, 5)
        }
        .background(Color.white)
        .opacity(self.isShowing ? 1 : 0)
        .cornerRadius(10)
      }
    }
  }
}

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

extension View {
  func aboutAlert(isShowing: Binding<Bool>) -> some View {
    AboutAlert(isShowing: isShowing,
               presenting: self)
  }
  
  func datePickerModalView(showModal: Binding<Bool>, dateText: Binding<String>) -> some View {
    DatePickerModalView(showModal: showModal, dateText: dateText, presenting: self)
  }
  
  func textAlert(isShowing: Binding<Bool>, text: Binding<String>) -> some View {
    TextAlert(isShowing: isShowing,
              presenting: self, text: text)
  }
}

//날짜 달력 뷰
struct DatePickerModalView<Presenting>: View where Presenting: View {
  @Binding var showModal: Bool
  @Binding var dateText: String
  @State var date: Date = Date()
  let presenting: Presenting
  
  var body: some View {
    ZStack{
      self.presenting
        .background(self.showModal ? Color.black : Color.clear)
        .opacity(self.showModal ? 0.5 : 1)
        .disabled(self.showModal)
        .onTapGesture { self.showModal = false }
      
      VStack {
        DatePicker("", selection: self.$date, displayedComponents: .date)
          .labelsHidden()
        
        HStack {
          Spacer()
          Button(action: {
            self.showModal.toggle()
          }, label: {
            Text("Cancel")
              .padding()
          })
          
          Spacer()
          
          Button(action: {
            self.dateText = self.dateFormatter.string(from: self.date)
            self.showModal.toggle()
          }, label: {Text("Ok").padding()})
          Spacer()
        }
      }
      .frame(width: 300)
      .background(Color.white)
      .opacity(self.showModal ? 1 : 0)
      .cornerRadius(10)
    }
  }
  
  var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }
}

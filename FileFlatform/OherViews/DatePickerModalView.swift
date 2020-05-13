//
//  DatePickerModalView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/11.
//  Copyright © 2020 mcsco. All rights reserved.
//
import SwiftUI

//날짜 달력 뷰
struct DatePickerModalView: View {
  @Binding var showModal: Bool
  @Binding var date: Date
  @Binding var dateText: String
  
  var body: some View {
    VStack {
      Text("Select a date")
        .font(.title)
      
      DatePicker("", selection: self.$date, displayedComponents: .date)
        .labelsHidden()
      
      Button(action: {
        self.dateText = self.dateFormatter.string(from: self.date)
        self.showModal.toggle()
      }) {
        Text("Ok")
          .font(.title)
      }
    }
  }
  
  var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }
}

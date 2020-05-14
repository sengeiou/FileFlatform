//
//  DatePickerView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/13.
//  Copyright © 2020 mcsco. All rights reserved.
//
import SwiftUI

struct DatePickerView: View {
  @Binding var showModal: Bool
  @State var date: Date = Date()
  @Binding var dateText: String

  var body: some View {
    VStack {
      DatePicker("", selection: self.$date, displayedComponents: .date)
        .labelsHidden()

      Button(action: {
        self.dateText = self.dateFormatter.string(from: self.date)
        self.showModal.toggle()
      }) {
        Text("Ok").frame(width: 50, height: 50, alignment: .center)
      }
    }
  }

  var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }
}

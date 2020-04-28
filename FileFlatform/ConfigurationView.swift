//
//  ConfigurationView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/14.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct ConfigurationView: View {
  @EnvironmentObject var keyboard: KeyboardResponder
  @Binding var showConfig: Bool
  @State var showAcquisiton: Bool = false
  @State private var showDatePicker: Bool = false
  
  @State private var date: Date = Date()
  @State private var dateText: String = ""
  @State private var site: String = ""
  @State private var operate: String = ""
  @State private var measuringCO: String = ""
  @State private var object: String = ""
  @State private var coordinateX: String = ""
  @State private var coordinateY: String = ""
  @State private var sensorType: String = ""
  @State private var grid: String = ""
  @State private var comment: String = ""

  let dbHelper = DatabaseHelper()
  
  @ObservedObject var bleConnection =  BLEConnection() //여기 ObservedObject선언 후 observedable로 받아야 데이터 갱신이 ui로 보임. 정확하게 파악해서 수정해야함
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ScrollView(.vertical) {
          Spacer().frame(height: geometry.safeAreaInsets.top)
          VStack {
            
            HStack {
              Text(ConfigureType.date.rawValue)
                .padding()
              
              TextField("", text: self.$dateText)
              
              Image(systemName: "calendar")
                .imageScale(.large)
                .onTapGesture {
                  self.showDatePicker = true
              }
              .padding()
              .sheet(isPresented: self.$showDatePicker) {
                DatePickerModalView(showModal: self.$showDatePicker, date: self.$date, dateText: self.$dateText)
              }
              
            }.frame(width: geometry.size.width, height: 60)
              .background(Color.yellow)
              .cornerRadius(20)
              .padding(.top)
            
            
            Group {
              InputTextView(title: ConfigureType.site.rawValue, inputText: self.$site)
              
              InputTextView(title: ConfigureType.object.rawValue, inputText: self.$object)
              
              InputTextView(title: ConfigureType.operate.rawValue, inputText: self.$operate)
              
              InputTextView(title: ConfigureType.measuringCO.rawValue, inputText: self.$measuringCO)
            }
            
            Group {
              InputTextView(title: ConfigureType.sensorType.rawValue, inputText: self.$sensorType)
              
              InputTextView(title: ConfigureType.coordinateX.rawValue, inputText: self.$coordinateX)
              
              InputTextView(title: ConfigureType.coordinateY.rawValue, inputText: self.$coordinateY)
              
              InputTextView(title: ConfigureType.grid.rawValue, inputText: self.$grid)
              
              InputTextView(title: ConfigureType.comment.rawValue, inputText: self.$comment)
            }
          }
          .background(Color.blue)
        }
        .frame(width: geometry.size.width, height: geometry.size.height-60, alignment: .top)
        .background(Color.red)
        .cornerRadius(30)
        
        
      }
      .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
      .background(Color.green)
      

      NavigationLink(destination: AquisitionView(gridConfig: ConfigDataForGrid(configX: Int(self.coordinateX) ?? 1, configY: Int(self.coordinateY) ?? 1), showConfig: self.$showConfig, bleConnection: self.bleConnection), isActive: self.$showAcquisiton) {
        Button(action: {
          let configData = ConfigureData()
          configData.data[ConfigureType.version.rawValue] = "Cori1.1"
          configData.data[ConfigureType.build.rawValue] = "20501212"
          configData.data[ConfigureType.date.rawValue] = self.dateText
          configData.data[ConfigureType.site.rawValue] = self.site
          configData.data[ConfigureType.operate.rawValue] = self.operate
          configData.data[ConfigureType.measuringCO.rawValue] = self.measuringCO
          configData.data[ConfigureType.object.rawValue] = self.object
          configData.data[ConfigureType.coordinateX.rawValue] = self.coordinateX
          configData.data[ConfigureType.coordinateY.rawValue] = self.coordinateY
          configData.data[ConfigureType.sensorType.rawValue] = self.sensorType
          configData.data[ConfigureType.grid.rawValue] = self.grid
          configData.data[ConfigureType.comment.rawValue] = self.comment
          
          let dbHelper = DatabaseHelper()
          if dbHelper.openDatabase() {
            dbHelper.createConfigTable()
            dbHelper.insertConfigRow() //이미 생성됐다면 새로 넣지는 않음
            
            for column in ConfigureType.allCases {
              dbHelper.updateConfigRow(column: column.rawValue, value: configData.data[column.rawValue] ?? "")
            }
          }
          
          self.showAcquisiton = true
        }) {
          Text("START ACQUISITION")
          .frame(width: geometry.size.width, height: 60)
          .background(Color.orange)
          .cornerRadius(20)
        }
      }
      .isDetailLink(false)
      .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
    }
    .navigationBarTitle("Configuration", displayMode: .inline)
    .padding(.bottom, keyboard.currentHeight)
    .edgesIgnoringSafeArea(.bottom)
    .animation(.easeOut(duration: 0.16))
    
    //처음 로딩시 처리 init개념으로 사용
    .onAppear(perform: {
      let dbHelper = DatabaseHelper()
      if dbHelper.openDatabase() {
        let configData = dbHelper.readConfigRow()
        
        self.dateText = configData.data[ConfigureType.date.rawValue] ?? ""
        self.site = configData.data[ConfigureType.site.rawValue] ?? ""
        self.operate = configData.data[ConfigureType.operate.rawValue] ?? ""
        self.measuringCO = configData.data[ConfigureType.measuringCO.rawValue] ?? ""
        self.object = configData.data[ConfigureType.object.rawValue] ?? ""
        self.coordinateX = configData.data[ConfigureType.coordinateX.rawValue] ?? ""
        self.coordinateY = configData.data[ConfigureType.coordinateY.rawValue] ?? ""
        self.sensorType = configData.data[ConfigureType.sensorType.rawValue] ?? ""
        self.grid = configData.data[ConfigureType.grid.rawValue] ?? ""
        self.comment = configData.data[ConfigureType.comment.rawValue] ?? ""
      }
      dbHelper.db = nil
    })
  }
}

struct ConfigurationView_Previews: PreviewProvider {
  static var previews: some View {
    ConfigurationView(showConfig: .constant(true))
  }
}

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

struct InputTextView: View {
  @State var title: String
  @Binding var inputText: String
  
  var body: some View {
    HStack {
      Text(self.title)
        .padding()
      
      TextField("", text: self.$inputText)
    }
    .lineLimit(nil)
    .frame(height: 60)
    .background(Color.yellow)
    .cornerRadius(20)
  }
}



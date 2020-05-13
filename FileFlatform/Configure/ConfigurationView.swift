//
//  ConfigurationView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/14.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//설정 정보를 입력하는 창
struct ConfigurationView: View {
  @EnvironmentObject var keyboard: KeyboardResponder //키보드 입력시 키보드 길이만큼 화면 줄임
  
  @Binding var showLinkViews: Bool //취득화면에서 뒤로 가기 했을때 같이 닫히게 하기위해(메인화면 복귀)
  @State var showAcquisiton: Bool = false //다음으로 넘어갈 취득뷰 토글
  @Binding var viewMode: ConfigureViewMod //입력모드인지 수정모드인지 결정
  @Binding var editURL: URL //수정모드일때 수정하는 url
  private var editedConfigure: () -> Void //수정모드이면 save 클릭시 처리하는 함수는 밖으로 뺌
  
  //@Binding var configData: ConfigureData
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
  
  @State private var showDatePicker: Bool = false //달력뷰 보여주는거 토글
  @State var showSheetX = false
  @State var showSheetY = false
  @State var showSheetSeonsor = false
  @State var showSheetGrid = false
  
  @ObservedObject var bleConnection =  BLEConnection() //여기 ObservedObject선언 후 observedable로 받아야 데이터 갱신이 ui로 보임. 정확하게 파악해서 수정해야함

  init(showConfig: Binding<Bool>, editedConfigure: @escaping () -> Void, viewMode: Binding<ConfigureViewMod>, editURL: Binding<URL>) {
    self.editedConfigure = editedConfigure
    self._showLinkViews = showConfig
    self._viewMode = viewMode
    self._editURL = editURL
  }
  
  //오른쪽 타이틀바 아이콘
  var rightBarIcons : some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Button(action: {
        self.dateText = ""
        self.site = ""
        self.operate = ""
        self.measuringCO = ""
        self.object = ""
        self.coordinateX = "4"
        self.coordinateY = "4"
        self.sensorType = SensorName.Rod.rawValue
        self.grid = "50"
        self.comment = ""
      }, label: {
        Image(systemName: "paintbrush")
          .frame(width: 30, height: 30, alignment: .center)
      })
    }
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 0) {
        Group {
          ScrollView(.vertical, showsIndicators: false) {
            //상단에 공백을 줘야 스크롤뷰가 타이틀바에 가려지지 않음.. 이상하게 필요 없어짐;;
//            Spacer()
//              .frame(height: geometry.safeAreaInsets.top)
            
            VStack(alignment: .leading, spacing: 5) {
              HStack {
                InputTextView(title: ConfigureType.date, inputText: self.$dateText)
                
                Image(systemName: "calendar")
                  .imageScale(.large)
                  .foregroundColor(Color(textFieldForegroundColor))
                  .onTapGesture {
                    self.showDatePicker = true}
                  .padding(.trailing, 10)
              }
              .frame(height: 50)
              .background(Color(textFieldBackgroudColor))
              .cornerRadius(10)
              .padding(.top)
              
              Group {
                InputTextView(title: ConfigureType.site, inputText: self.$site)
                
                InputTextView(title: ConfigureType.object, inputText: self.$object)
                
                InputTextView(title: ConfigureType.operate, inputText: self.$operate)
                
                InputTextView(title: ConfigureType.measuringCO, inputText: self.$measuringCO)
              }
              
              Group {
                InputTextView(title: ConfigureType.sensorType, inputText: self.$sensorType, inputDisable: true)
                  .actionSheet(isPresented: self.$showSheetSeonsor) {
                    ActionSheet(title: Text("\(ConfigureType.sensorType.rawValue)"), buttons:[
                      Alert.Button.default(Text("\(SensorName.Rod.rawValue)"), action: {self.sensorType = SensorName.Rod.rawValue}),
                      Alert.Button.default(Text("\(SensorName.Wheel.rawValue)"), action: {self.sensorType = SensorName.Wheel.rawValue}), .cancel()])}
                  .onTapGesture {
                    self.showSheetSeonsor = true
                    self.endEditing()}
                
                InputTextView(title: ConfigureType.coordinateX, inputText: self.$coordinateX, inputDisable: true)
                  .actionSheet(isPresented: self.$showSheetX) {
                    ActionSheet(title: Text("\(ConfigureType.coordinateX.rawValue)"), buttons:[
                      Alert.Button.default(Text("1"), action: {self.coordinateX = "1"}),
                      Alert.Button.default(Text("2"), action: {self.coordinateX = "2"}),
                      Alert.Button.default(Text("3"), action: {self.coordinateX = "3"}),
                      Alert.Button.default(Text("4"), action: {self.coordinateX = "4"}),
                      Alert.Button.default(Text("5"), action: {self.coordinateX = "5"}),
                      Alert.Button.default(Text("6"), action: {self.coordinateX = "6"}),
                      Alert.Button.default(Text("7"), action: {self.coordinateX = "7"}),
                      Alert.Button.default(Text("8"), action: {self.coordinateX = "8"}),
                      Alert.Button.default(Text("9"), action: {self.coordinateX = "9"}),
                      Alert.Button.default(Text("10"), action: {self.coordinateX = "10"}),
                      Alert.Button.default(Text("11"), action: {self.coordinateX = "11"}),
                      Alert.Button.default(Text("12"), action: {self.coordinateX = "12"}), .cancel()])}
                  .onTapGesture { self.showSheetX = true
                    self.endEditing()}
                
                InputTextView(title: ConfigureType.coordinateY, inputText: self.$coordinateY, inputDisable: true)
                  .actionSheet(isPresented: self.$showSheetY) {
                    ActionSheet(title: Text("\(ConfigureType.coordinateY.rawValue)"), buttons:[
                      Alert.Button.default(Text("1"), action: {self.coordinateY = "1"}),
                      Alert.Button.default(Text("2"), action: {self.coordinateY = "2"}),
                      Alert.Button.default(Text("3"), action: {self.coordinateY = "3"}),
                      Alert.Button.default(Text("4"), action: {self.coordinateY = "4"}),
                      Alert.Button.default(Text("5"), action: {self.coordinateY = "5"}),
                      Alert.Button.default(Text("6"), action: {self.coordinateY = "6"}),
                      Alert.Button.default(Text("7"), action: {self.coordinateY = "7"}),
                      Alert.Button.default(Text("8"), action: {self.coordinateY = "8"}),
                      Alert.Button.default(Text("9"), action: {self.coordinateY = "9"}),
                      Alert.Button.default(Text("10"), action: {self.coordinateY = "10"}), .cancel()])}
                  .onTapGesture { self.showSheetY = true
                    self.endEditing() }
                
                InputTextView(title: ConfigureType.grid, inputText: self.$grid, inputDisable: true)
                  .actionSheet(isPresented: self.$showSheetGrid) {
                    ActionSheet(title: Text("\(ConfigureType.grid.rawValue)"), buttons:[
                      Alert.Button.default(Text("50"), action: {self.grid = "50"}),
                      Alert.Button.default(Text("150"), action: {self.grid = "150"}),
                      Alert.Button.default(Text("200"), action: {self.grid = "200"}),
                      Alert.Button.default(Text("250"), action: {self.grid = "250"}), .cancel()])}
                  .onTapGesture { self.showSheetGrid = true
                    self.endEditing() }
                
                InputTextView(title: ConfigureType.comment, inputText: self.$comment)
              }
            }
          }.padding([.bottom, .leading, .trailing])
        }
        .background(Color.white)
        .cornerRadius(radius: 20, corners: .topLeft)
        .cornerRadius(radius: 20, corners: .topRight)
        
        //입력하는 화면일때
        if self.viewMode == .input {
          NavigationLink(destination: AquisitionView(gridConfig: ConfigDataForGrid(configX: Int(self.coordinateX) ?? 0, configY: Int(self.coordinateY) ?? 0), showLinkViews: self.$showLinkViews, bleConnection: self.bleConnection), isActive: self.$showAcquisiton) {
            
            UnderButtonView(title: "START ACQUISITION", clickEvent: {
              //DB에 입력한 정보 저장
              let configData = self.getConfigureData()
              
              let dbHelper = DatabaseHelper()
              if dbHelper.openDatabase() {
                dbHelper.createConfigTable()
                dbHelper.insertConfigRow() //이미 생성됐다면 새로 넣지는 않음
                
                for column in ConfigureType.allCases {
                  dbHelper.updateConfigRow(column: column.rawValue, value: configData.data[column.rawValue] ?? "")
                }
              }
              
              self.showAcquisiton = true
            })
          }
          .isDetailLink(false)
        } else { //파일관리화면에서 수정하는 화면일때
          UnderButtonView(title: "Save", clickEvent: {
            //수정한 정보를 파일에 씀
            let fileStream = FileStream()
            let configData = self.getConfigureData()
            
            let acData = fileStream.readAcData(url: self.editURL)
            fileStream.writeConfigureData(url: self.editURL, configData: configData)
            fileStream.writeAcquisitonData(url: self.editURL, acData: acData)
            
            self.editedConfigure()
            self.showLinkViews = false
          })
        }
      }
      .datePickerModalView(showModal: self.$showDatePicker, dateText: self.$dateText)
    }
    .navigationBarItems(trailing: rightBarIcons)
    .navigationBarTitle("Configuration", displayMode: .inline)
    .padding(.bottom, keyboard.currentHeight)
    .background(Color(backgroundColor))
    .animation(.easeOut(duration: 0.16))
      //처음 로딩시 입력 모드면 입력했던 내용 보여주기
      .onAppear(perform: {        
        var configData: ConfigureData = ConfigureData()
        //입력 모드일때는 디비에 있는 정보를 가져옴
        if self.viewMode == .input {
          let dbHelper = DatabaseHelper()
          if dbHelper.openDatabase() {
            configData = dbHelper.readConfigRow()
          }
          dbHelper.db = nil
        } else { //수정 모드일때는 파일에 있는정보를 가져옴
          let fileStream = FileStream()
          configData = fileStream.readConfigData(url: self.editURL)
        }
        
        //불러온 데이타를 입력 데이타에 적용
        self.dateText = configData.data[ConfigureType.date.rawValue]!
        self.site = configData.data[ConfigureType.site.rawValue]!
        self.operate = configData.data[ConfigureType.operate.rawValue]!
        self.measuringCO = configData.data[ConfigureType.measuringCO.rawValue]!
        self.object = configData.data[ConfigureType.object.rawValue]!
        
        self.coordinateX = configData.data[ConfigureType.coordinateX.rawValue]!
        if self.coordinateX.isEmpty { self.coordinateX = "4"}
        
        self.coordinateY = configData.data[ConfigureType.coordinateY.rawValue]!
        if self.coordinateY.isEmpty { self.coordinateY = "4"}
        
        self.sensorType = configData.data[ConfigureType.sensorType.rawValue]!
        if self.sensorType.isEmpty { self.sensorType = SensorName.Rod.rawValue}
        
        self.grid = configData.data[ConfigureType.grid.rawValue]!
        if self.grid.isEmpty { self.grid = "50"}
        
        self.comment = configData.data[ConfigureType.comment.rawValue]!
      })
  }
  
  //사용자가 입력한 정보를 취합
  func getConfigureData()-> ConfigureData {
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
    
    return configData
  }
  
  private func endEditing() {
    UIApplication.shared.endEditing()
  }
}

struct ConfigurationView_Previews: PreviewProvider {
  static var previews: some View {
    ConfigurationView(showConfig: .constant(true), editedConfigure: {}, viewMode: .constant(.input), editURL: .constant(URL(fileURLWithPath: "")))
  }
}


//입력 텍스트 뷰
struct InputTextView: View {
  @State var title: ConfigureType
  @Binding var inputText: String
  @State var inputDisable = false
  var body: some View {
    
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Text(self.title.rawValue)
        .frame(width: 110, height: 50, alignment: .leading)
        .padding(.leading, 4)
        .foregroundColor(Color(textFieldForegroundColor))
      
      VStack(alignment: .leading, spacing: 0){
        
        TextField("", text: self.$inputText)
          .frame(height: 50, alignment: .leading)
          .onReceive(self.inputText.publisher.collect()) {
            //입력한 문자를 euc-kr로 인코딩했을때 저장 가능한 길이까지만 입력 받음
            var data = String($0).data(using: encoding)!
            let fixSize = self.getFixedSize(title: self.title)
            if data.count > fixSize {
              data = data.subdata(in: 0..<fixSize)
            }
            if data.count > 0 {
              self.inputText = String(data: data, encoding: encoding) ?? ""
            }}
          .disabled(self.inputDisable)
          .foregroundColor(Color.black)
        Divider()
          .background(Color(textFieldForegroundColor))
          .offset(y: -10)
      }
      .padding(.trailing, 10)
      
      if self.inputDisable {
        Image(systemName: "chevron.down")
          .padding(.trailing, 10)
          .foregroundColor(Color(textFieldForegroundColor))
      }
    }
    .background(Color(textFieldBackgroudColor))
    .cornerRadius(10)
  }
  
  //설정이름에 맞는 사이즈를 가져와야 하는데 데이타 설계를 잘못해서 일단 이렇게라도 가져옴
  //입력할 수 있는 최대길이
  func getFixedSize(title: ConfigureType)-> Int {
    var size: Int = 0
    switch title {
    case .version:
      size = FixSize().version
      break
    case .build:
      size = FixSize().build
      break
    case .date:
      size = FixSize().date
      break
    case .site:
      size = FixSize().site
      break
    case .operate:
      size = FixSize().operate
      break
    case .measuringCO:
      size = FixSize().measuringCo
      break
    case .object:
      size = FixSize().object
      break
    case .coordinateX:
      size = FixSize().coordinateX
      break
    case .coordinateY:
      size = FixSize().coordinateY
      break
    case .sensorType:
      size = FixSize().sensorType + 10
      break
    case .grid:
      size = FixSize().grid
      break
    case .comment:
      size = FixSize().comment
      break
    }
    
    return size
  }
}


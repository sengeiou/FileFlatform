//
//  AquisitionView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/15.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct AquisitionView: View {
  @State var gridConfig: ConfigDataForGrid //좌표뷰에 사용되는 데이터들
  @Binding var showConfig: Bool //main 화면으로 바로 복귀하기 위해서
  
  @State var selectSaveURL: URL = getDocumentDirectory() //save화면에서 선택한 저장경로
  @State var showSaveDirectory: Bool = false // save 경로선택 화면
  @State private var fileName: String = "TemporaryName.SCM" //저장할때 보여주는 임시 파일명
  
  @State var showHoldAlert: Bool = false
  @State var showSaveAlert: Bool = false
  
  @ObservedObject var bleConnection: BLEConnection //블루투스 관련
  
  @State var holdAcquisitionData: String = ""
  var btnBack : some View {
    HStack {
      Button(action: {
        self.showConfig = false
        self.bleConnection.connectType = BLEConnectType.doneConnection.rawValue
        self.bleConnection.cacelConection()
      }) {
        Text("Done")
      }
    }
  }
  
  var saveView : some View {
    HStack {
      Image(systemName: "tray.and.arrow.down")
        .imageScale(.large)
        .onTapGesture {
          self.showSaveDirectory = true
      }
    }
  }
  
  var body: some View {
    VStack {
      Button(action: {
        self.bleConnection.connectType = BLEConnectType.scanMode.rawValue
        self.bleConnection.cacelConection()
        self.bleConnection.selfShow = true
        
      }, label: {Text("DeviceSearch")})
      
      Text("BATTERY_LEVEL : \(self.bleConnection.battery)")
      
      Text("TEMPERATURE : \(self.bleConnection.temperature)")
      
      Button(action: {
        
        self.bleConnection.cacelConection()
        
      }, label: {Text("Cancel")})
      
      AcquisitionGridView(config: self.gridConfig)
        .onAppear() {
          self.gridConfig.cells[0].color = self.gridConfig.revealCellColor
          self.gridConfig.setRowColumnColor(color: self.gridConfig.selRowColumnTextColor)
      }
      
      Button(action: {
        self.holdAcquisitionData = self.bleConnection.temperature
        self.showHoldAlert = true
      }, label: {Text("Hold")})
        .actionSheet(isPresented: self.$showHoldAlert) {
          ActionSheet(title: Text("X:\(self.gridConfig.getRealCoordinateX()) , Y:\(self.gridConfig.getRealCoordinateY())"), message: Text("\(self.holdAcquisitionData) mV"), buttons: [
            .default(Text("Ok")){
              //해당 cell에 취득 데이타 쓰기
              self.gridConfig.cells[self.gridConfig.selIndex].acData = self.holdAcquisitionData
              //마지막 cell이였으면 파일로 저장할지 물음
              if self.gridConfig.lastCheckBeforMove() {
                self.showSaveAlert = true
              }
              //다음 cell로 이동
              self.gridConfig.moveToNext() },
            .cancel()
          ])
      }
      .alert(isPresented: self.$showSaveAlert, content: {
        Alert(title: Text("Save as a file?"), message: Text("last data saved"), primaryButton: .default(Text("Ok"), action: {
          self.showSaveDirectory = true
        }), secondaryButton: .cancel())
      })

      //저장시 열리는 네비게이션창
      NavigationLink(destination: SaveDirectoryView(selectSaveURL: self.$selectSaveURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showSaveDirectory, fileName: self.$fileName, seletionPicker: {
        
        var acData: [Int16] = Array() //나중에는 실제 취득데이타
        for i in 0..<self.gridConfig.cells.count {
          acData.append(Int16(self.gridConfig.cells[i].acData) ?? Int16.max)
        }
        
        let dbHelper = DatabaseHelper()
        if dbHelper.openDatabase() {
          let configData = dbHelper.readConfigRow()
          let fileStream = FileStream()
          fileStream.writeConfigureData(url: self.selectSaveURL, configData: configData, acData: acData)
        }
      }), isActive: self.$showSaveDirectory, label: {EmptyView()}).hidden()
      
      //알림 용도로 사용하는 보이지 않는 뷰
      Text("")
        .alert(isPresented: self.$bleConnection.bluetoohUnauthorizedShow, content: {
          Alert(title: Text("Bluetooth is Unauthorized"), message: Text("Go for Bluetooth authentication"), primaryButton: .default(Text("Ok"), action: {
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
          }), secondaryButton: .cancel())
        })
      
      Text("")
        .alert(isPresented: self.$bleConnection.bluetoohUnsupportedShow, content: {
          Alert(title: Text("Bluetooth is Unsupported"), message: Text("Can't run program"), dismissButton: .default(Text("Ok")))
        })
    }
      .navigationBarBackButtonHidden(true) //원래 아이콘은 안보이게 함
      .navigationBarItems(leading: btnBack, trailing: saveView) //상단에 아이콘
      .navigationBarTitle("Acquisiton") //타이틀
      .onAppear(){
        let dbHelper = DatabaseHelper()
        if dbHelper.openDatabase() {
          let uuid: String = dbHelper.readBluetoothDeviceUUID()
          self.bleConnection.startCentralManager()
          
          if uuid.isEmpty {
            self.bleConnection.selfShow = true
            self.bleConnection.connectType = BLEConnectType.scanMode.rawValue
          } else {
            self.bleConnection.connectType = BLEConnectType.autoConnectMode.rawValue
            self.bleConnection.autoConectUUID = uuid
          }
        }
      }
      .sheet(isPresented: self.$bleConnection.selfShow, content: {
        FindBluetoothDeviceView(bleConnection: self.bleConnection)
      })
  }
}

struct AquisitionView_Previews: PreviewProvider {
  static var previews: some View {
    AquisitionView(gridConfig: ConfigDataForGrid(configX: 1, configY: 1), showConfig: .constant(true), bleConnection: BLEConnection())
  }
}



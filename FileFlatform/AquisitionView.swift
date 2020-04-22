//
//  AquisitionView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/15.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct AquisitionView: View {
  @Binding var showConfig: Bool //main 화면으로 바로 복귀하기 위해서
  @State var selectSaveURL: URL = getDocumentDirectory() //save화면에서 선택한 저장경로
  @State var showSaveDirectory: Bool = false // save 경로선택 화면
  @State private var fileName: String = "TemporaryName.SCM" //저장할때 보여주는 임시 파일명
  @ObservedObject var bleConnection: BLEConnection
  
  var btnBack : some View {
    HStack {
      Button(action: { self.showConfig = false }) {
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
        self.bleConnection.cacelConection()
        self.bleConnection.selfShow = true
        
      }, label: {Text("DeviceSearch")})
      
      Text("BATTERY_LEVEL : \(self.bleConnection.battery)")
      
      Text("TEMPERATURE : \(self.bleConnection.temperature)")
      
      Button(action: {
        
        self.bleConnection.cacelConection()
        
      }, label: {Text("Cancel")})
      
      NavigationLink(destination: SaveDirectoryView(selectSaveURL: self.$selectSaveURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showSaveDirectory, fileName: self.$fileName, seletionPicker: {
        
        let acData: [Int16] = Array() //나중에는 실제 취득데이타
        
        let dbHelper = DatabaseHelper()
        if dbHelper.openDatabase() {
          let configData = dbHelper.readConfigRow()
          let fileStream = FileStream()
          fileStream.writeConfigureData(url: self.selectSaveURL, configData: configData, acData: acData)
        }
      }), isActive: self.$showSaveDirectory, label: {EmptyView()}).hidden()
      
      
      
      //알림 용도로 임시뷰
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
    .onDisappear() {
      self.bleConnection.cacelConection()
    }
    .sheet(isPresented: self.$bleConnection.selfShow, content: {
      FindBluetoothDeviceView(bleConnection: self.bleConnection)
    })
  }
}

struct AquisitionView_Previews: PreviewProvider {
  static var previews: some View {
    AquisitionView(showConfig: .constant(true), bleConnection: BLEConnection())
  }
}



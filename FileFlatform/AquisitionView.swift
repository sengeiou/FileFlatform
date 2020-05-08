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
  @Binding var showLinkViews: Bool //main 화면으로 바로 복귀하기 위해서
  
  @State var selectSaveURL: URL = getDocumentDirectory() //save화면에서 선택한 저장경로
  @State var showSaveDirectory: Bool = false // save 경로선택 화면
  @State private var fileName: String = "TemporaryName.scm" //저장할때 보여주는 임시 파일명
  
  @State var showHoldAlert: Bool = false
  @State var showSaveAlert: Bool = false
  
  @ObservedObject var bleConnection: BLEConnection //블루투스 관련
  
  @State var holdAcquisitionData: String = ""
  
  var leftBarIcons : some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Button(action: {
        self.showLinkViews = false
        self.bleConnection.connectType = BLEConnectType.doneConnection.rawValue
        self.bleConnection.cacelConection()
      }) {
        Text("Done")
      }
    }
  }
  
  var rightBarIcons : some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      //연결 상태 및 연결 끊기
      Button(action: {
        self.bleConnection.connectType = BLEConnectType.scanMode.rawValue
        self.bleConnection.cacelConection()
        self.bleConnection.selfShow = true
      }, label: {
        if self.bleConnection.connectionOn {
          Image(systemName: "wifi")
            .frame(width: 30, height: 30, alignment: .center)
        } else {
          Image(systemName: "wifi.slash")
            .frame(width: 30, height: 30, alignment: .center)
        }
      })
      
      //배터리
      Button(action: {
      }, label: {
        if Int(self.bleConnection.battery) ?? 0 > 80 {
          Image(systemName: "10.square")
            .frame(width: 30, height: 30, alignment: .center)
        } else if Int(self.bleConnection.battery) ?? 0 > 60 {
          Image(systemName: "8.square")
            .frame(width: 30, height: 30, alignment: .center)
        } else if Int(self.bleConnection.battery) ?? 0 > 40 {
          Image(systemName: "6.square")
            .frame(width: 30, height: 30, alignment: .center)
        } else if Int(self.bleConnection.battery) ?? 0 > 20 {
          Image(systemName: "4.square")
            .frame(width: 30, height: 30, alignment: .center)
        } else if Int(self.bleConnection.battery) ?? 0 > 5 {
          Image(systemName: "2.square")
            .frame(width: 30, height: 30, alignment: .center)
        } else {
          Image(systemName: "0.square")
            .frame(width: 30, height: 30, alignment: .center)
        }
      })
      
      //0점 잡기
      Button(action: {
      }, label: {
        Image(systemName: "stop.circle")
          .frame(width: 30, height: 30, alignment: .center)
      })
      
      //파일 저장
      Button(action: {
        self.showSaveDirectory = true
      }, label: {
        Image(systemName: "tray.and.arrow.down")
          .frame(width: 30, height: 30, alignment: .center)
      })
    }
  }
  
  func saveFile() {
    var acData: [Int16] = Array() //나중에는 실제 취득데이타
    for i in 0..<self.gridConfig.cells.count {
      acData.append(Int16(self.gridConfig.cells[i].acData) ?? Int16.max)
    }
    
    let dbHelper = DatabaseHelper()
    if dbHelper.openDatabase() {
      let configData = dbHelper.readConfigRow()
      let fileStream = FileStream()
      fileStream.writeConfigureData(url: self.selectSaveURL, configData: configData)
      fileStream.writeAcquisitonData(url: self.selectSaveURL, acData: acData, configX: self.gridConfig.configX, configY: self.gridConfig.configY)
    }
  }
  
  func startBluetooth() {
    //연결이 되어 있지 않다면
    if !self.bleConnection.connectionOn {
      let dbHelper = DatabaseHelper()
      if dbHelper.openDatabase() {
        let uuid: String = dbHelper.readBluetoothDeviceUUID()
        
        //uuid가 존재하지 않다면 스캔모드
        if uuid.isEmpty {
          self.bleConnection.connectType = BLEConnectType.scanMode.rawValue
        } else { //uuid가 있다면 자동연결 시도
          self.bleConnection.connectType = BLEConnectType.autoConnectMode.rawValue
          self.bleConnection.autoConectUUID = uuid
        }
      }
      
      //핸드폰의 블루투스 매니저가 파워온 상태가 아니면. 중복 start시 동작 안됨
      if !self.bleConnection.CentralPowerON() {
        self.bleConnection.startCentralManager()
      }
    }
  }

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      ZStack{
        Rectangle()
          .frame(height: 97)
          .background(Color.white)
          .cornerRadius(10)
          .padding(.bottom, 3)
          .padding(.leading, 5)
          .padding(.trailing, 5)
        
        if self.bleConnection.connectionOn {
          //Text("BATTERY_LEVEL : \(self.bleConnection.battery)")
          Text("\(self.bleConnection.temperature) mV")
            .foregroundColor(Color.black)
            .font(.system(size: 60))
            .bold()
        } else {
          CircleProgressBar(lineStroke: 8.0)
        }
      }
      .frame(height: 100)
      
      AcquisitionGridView(config: self.gridConfig)
        .onAppear() {
          if self.gridConfig.cells.count > 0 {
            self.gridConfig.cells[0].color = self.gridConfig.revealCellColor
            self.gridConfig.setRowColumnColor(color: self.gridConfig.selRowColumnTextColor)
          }
      }
      
      GradationExampleView()
      
      UnderButtonView(title: "Hold", clickEvent: {
        if self.gridConfig.cells.count > 0 {
          self.holdAcquisitionData = self.bleConnection.temperature
          self.showHoldAlert = true
        }
      })
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
          ])}
        .alert(isPresented: self.$showSaveAlert, content: {
          Alert(title: Text("Save as a file?"), message: Text("last data saved"), primaryButton: .default(Text("Ok"), action: {
            self.showSaveDirectory = true
          }), secondaryButton: .cancel())
        })
      
      
      //저장시 열리는 네비게이션창
      NavigationLink(destination: SaveDirectoryView(selectSaveURL: self.$selectSaveURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showSaveDirectory, fileName: self.$fileName, extention: .constant("scm"), seletionPicker: {self.saveFile()}), isActive: self.$showSaveDirectory, label: {EmptyView()})
      
      //알림 용도로 사용하는 보이지 않는 뷰
      EmptyView()
        .alert(isPresented: self.$bleConnection.bluetoohUnauthorizedShow, content: {
          Alert(title: Text("Bluetooth is Unauthorized"), message: Text("Go for Bluetooth authentication"), primaryButton: .default(Text("Ok"), action: {
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
          }), secondaryButton: .cancel(Text("Cancel"), action: {self.showLinkViews = false}))
        })
      
      EmptyView()
        .alert(isPresented: self.$bleConnection.bluetoohUnsupportedShow, content: {
          Alert(title: Text("Bluetooth is Unsupported"), message: Text("Can't run program"), dismissButton: .default(Text("Ok"), action: {self.showLinkViews = false} ))
        })
    }
      .navigationBarBackButtonHidden(true) //원래 아이콘은 안보이게 함
      .navigationBarItems(leading: leftBarIcons, trailing: rightBarIcons) //상단에 아이콘
      .navigationBarTitle("Acquisiton") //타이틀
      .onAppear(){self.startBluetooth()}
      .sheet(isPresented: self.$bleConnection.selfShow, content: {FindBluetoothDeviceView(bleConnection: self.bleConnection)})
  }
}

struct AquisitionView_Previews: PreviewProvider {
  static var previews: some View {
    AquisitionView(gridConfig: ConfigDataForGrid(configX: 1, configY: 1), showLinkViews: .constant(true), bleConnection: BLEConnection())
  }
}




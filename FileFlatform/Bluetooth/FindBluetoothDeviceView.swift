//
//  FindBluetoothDeviceView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/21.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

//블루투스 디바이스를 찾는 스캔창
struct FindBluetoothDeviceView: View {
  @ObservedObject var bleConnection: BLEConnection
  @State var tryConnect: Bool = false
  @State var deviceName: String = ""
  @State var deviceAddress: String = ""
  
  var body: some View {
    GeometryReader{ geometry in
      VStack(alignment: .center, spacing: 0) {
        Text("Device Searching")
          .frame(width: geometry.size.width, alignment: .center)
          .font(.headline)
        
        RectangleProgressBar().frame(height: 5)
          .padding(.bottom, 2)
        
        //검색된 디바이스 리스트
        ScrollView(.vertical, showsIndicators: false) {
          ForEach(self.bleConnection.scannedBLEDevices, id: \.self) { device in
            Button(action: {
              //연결 시도
              self.deviceName = device.peripheral.name ?? ""
              self.deviceAddress = device.peripheral.identifier.uuidString
              
              self.tryConnect = true
              self.bleConnection.tryConnect(connectPeripheral: device.peripheral)
            }, label: {
              VStack(alignment: .leading, spacing: 1){
                Text("Name : \(device.peripheral.name ?? "")")
                Text("Address : \(device.peripheral.identifier.uuidString)")
                Text("RSSI : \(device.rssi)")
                Divider()
              }
            })
              .frame(width: geometry.size.width, alignment: .leading)
              
          }
        }

        HStack(alignment: .top, spacing: 0){
          VStack(alignment: .leading, spacing: 0) {
            Text("name: \(self.deviceName)")
              .lineLimit(1)
              .frame(height: 25, alignment: .center)
            Text("address: \(self.deviceAddress)")
              .lineLimit(1)
              .frame(height: 25, alignment: .center)
          }
          Spacer()
          if self.tryConnect {
            Text("Connecting")
              .frame(height: 50, alignment: .center)
            CircleProgressBar(lineStroke: 4)
              .frame(width: 50, height: 50, alignment: .center)
          }
        }
        .frame(width: geometry.size.width-4, height: 50, alignment: .leading)
        .background(Color(backgroundColor))
        .cornerRadius(5)
      
        
      }
      .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
      .onAppear() {
        self.bleConnection.scannedBLEDevices.removeAll()
        self.bleConnection.startScan()
      }
      .onDisappear() {
        self.bleConnection.cacelScan()
        
        //연결을 성공하지 못하고 닫을 시 기존 디바이스로 재연결
        if !self.bleConnection.connectionOn {
          let dbHelper = DatabaseHelper()
          if dbHelper.openDatabase() {
            let uuid: String = dbHelper.readBluetoothDeviceUUID()
            if !uuid.isEmpty {
              self.bleConnection.tryConnect(uuid: UUID(uuidString: uuid) ?? UUID())
            }
          }
        }
      }
    }.padding(.all, 5)
  }
}

struct FindBluetoothDeviceView_Previews: PreviewProvider {
  static var previews: some View {
    FindBluetoothDeviceView(bleConnection: BLEConnection())
  }
}


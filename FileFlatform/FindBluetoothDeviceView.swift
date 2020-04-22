//
//  FindBluetoothDeviceView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/21.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct FindBluetoothDeviceView: View {
  @ObservedObject var bleConnection: BLEConnection
  
  var body: some View {
    VStack {
      Text("Device Searching")
      
      List(self.bleConnection.scannedBLEDevices, id: \.self) { device in
        Text("\(device.peripheral.name ?? "") + \(device.rssi)")
          .onTapGesture {

            let dbHelper = DatabaseHelper()
            if dbHelper.openDatabase() {
              dbHelper.createBluetoothDeviceTable()
              dbHelper.insertBluetoothDeviceRow()
              
              dbHelper.updateBluetoothDeviceRow(column: BluetoothDeviceType.name.rawValue, value: device.peripheral.name ?? "")
              dbHelper.updateBluetoothDeviceRow(column: BluetoothDeviceType.uuid.rawValue, value: device.peripheral.identifier.uuidString)
            }
            self.bleConnection.tryConnect(connectPeripheral: device.peripheral)
        }
      }
    }
    .onAppear() {
      self.bleConnection.startScan()
    }
    .onDisappear() {
      self.bleConnection.cacelScan()
    }
  }
}

struct FindBluetoothDeviceView_Previews: PreviewProvider {
  static var previews: some View {
    FindBluetoothDeviceView(bleConnection: BLEConnection())
  }
}

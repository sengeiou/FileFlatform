//
//  ContentView.swift
//  BluetoothVer2
//
//  Created by SUNG KIM on 2020/04/20.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct ScanPeripheral: Hashable {
  var peripheral: CBPeripheral
  var rssi: NSNumber
}


open class BLEConnection: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
  
  // Properties
  private var centralManager: CBCentralManager! = nil
  private var peripheral: CBPeripheral!
  
  public var connectType: String = BLEConnectType.scanMode.rawValue
  public var autoConectUUID: String = ""
  //public static let bleServiceUUID = CBUUID.init(string: "XXXX")
  //public static let bleCharacteristicUUID = CBUUID.init(string: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX")
  
  // Array to contain names of BLE devices to connect to.
  // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
  @Published var scannedBLEDevices: [ScanPeripheral] = []
  @Published var battery: String = ""
  @Published var temperature: String = ""
  @Published var bluetoohUnauthorizedShow: Bool = false
  @Published var bluetoohUnsupportedShow: Bool = false
  @Published var selfShow: Bool = false
  
  func startCentralManager() {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
    print("Central Manager State: \(self.centralManager.state)")
  }
  
  func CenralPowerON()-> Bool {
    if (self.centralManager.state == CBManagerState.poweredOn) {
      return true
    } else {
      return false
    }
  }
  
  // Handles BT Turning On/Off
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch (central.state) {
    case .unsupported:
      print("BLE is Unsupported")
      self.bluetoohUnsupportedShow = true
      break
    case .unauthorized:
      print("BLE is Unauthorized")
      self.bluetoohUnauthorizedShow = true
      break
    case .unknown:
      print("BLE is Unknown")
      break
    case .resetting:
      print("BLE is Resetting")
      break
    case .poweredOff:
      print("BLE is Powered Off")
      break
    case .poweredOn:
      print("BLE is Powered ON")
      
      if(self.connectType == BLEConnectType.scanMode.rawValue) {
        self.startScan()
      }
      else if(self.connectType == BLEConnectType.autoConnectMode.rawValue) {
        self.tryConnect(uuid: UUID(uuidString: self.autoConectUUID) ?? UUID())
      }
      //한번 연결된 후 외부요인으로 끊겼을때(블루투스 꺼짐 등) 다시 재연결
      else if(self.connectType == BLEConnectType.didConnection.rawValue) {
        self.tryConnect(connectPeripheral: self.peripheral)
      }
      break
    @unknown default: break
    }
  }
  
  // Handles the result of the scan
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("Peripheral Name: \(String(describing: peripheral.name))  RSSI: \(String(RSSI.doubleValue))")
    
    if(!(peripheral.name?.isEmpty ?? true) ) {
      var insertCheck  = true
      for i in 0..<self.scannedBLEDevices.count {
        if self.scannedBLEDevices[i].peripheral.identifier == peripheral.identifier {
          self.scannedBLEDevices[i].rssi = RSSI
          insertCheck = false
          break
        }
      }
      
      if insertCheck {
        self.scannedBLEDevices.append(ScanPeripheral(peripheral: peripheral, rssi: RSSI))
      }
    }
  }
  
  //연결했을 때
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    if peripheral == self.peripheral {
      print("Connected to your BLE Board")
      self.connectType = BLEConnectType.didConnection.rawValue
      self.selfShow = false
      peripheral.discoverServices(nil)
    }
  }
  
  //연결 중에 연결이 끊어졌을 때
  public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    print("didDisconnectPeripheral : \(error?.localizedDescription ?? "")")
    if(self.connectType == BLEConnectType.didConnection.rawValue) {
      self.centralManager.connect(self.peripheral, options: nil)
    }
  }
  
  //디바이스 연결 실패인데 한번도 호출 된건 못봄
  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("didFailToConnect")
  }
  
  public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
    //
  }
    
  public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    //
  }
  
  public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
    //
  }
  
  public func tryConnect(connectPeripheral: CBPeripheral) {
    // We've found it so stop scan
    self.cacelScan()
    self.cacelConection()
    // Copy the peripheral instance
    self.peripheral = connectPeripheral
    self.peripheral.delegate = self
    // Connect!
    self.centralManager.connect(self.peripheral, options: nil)
  }

  public func cacelScan() {
    if self.centralManager.isScanning {
      self.centralManager.stopScan()
    }
  }
  
  public func startScan() {
    if self.centralManager.isScanning {
      self.centralManager.stopScan()
    }
    self.centralManager.scanForPeripherals(withServices: nil,options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
  }
  
  public func cacelConection() {
    if self.peripheral != nil {
      self.centralManager.cancelPeripheralConnection(self.peripheral)
    }
  }
  
  public func tryConnect(uuid: UUID) {
    let peripherals = self.centralManager.retrievePeripherals(withIdentifiers: [uuid])
    if peripherals.count > 0 {
      self.tryConnect(connectPeripheral: peripherals.first!)
    }
  }
  
  // Handles discovery event
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let services = peripheral.services {
      for service in services {
        if service.uuid == UUID_SERVICE_BATTERY || service.uuid == UUID_SERVICE_ENVIRONMENT_SENSING {
          print("BLE Service found")
          //Now kick off discovery of characteristics
          peripheral.discoverCharacteristics(nil, for: service)
        }
      }
    }
  }
  
  // Handling discovery of characteristics
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        if characteristic.uuid == UUID_CHARACTERISTIC_BATTERY_LEVEL {
          peripheral.readValue(for: characteristic)
        }
        else if characteristic.uuid == UUID_CHARACTERISTIC_TEMPERATURE{
          //peripheral.readValue(for: characteristic)
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
    if characteristic.uuid == UUID_CHARACTERISTIC_BATTERY_LEVEL {
      print("UUID_CHARACTERISTIC_BATTERY_LEVEL : \(characteristic)")
      let copy = UnsafeMutableRawBufferPointer.allocate(byteCount: 1, alignment: MemoryLayout<UInt>.alignment)
      characteristic.value?.copyBytes(to: copy)
      self.battery = String(copy.load(as: Int8.self))
    }
    else if characteristic.uuid == UUID_CHARACTERISTIC_TEMPERATURE{
      print("UUID_CHARACTERISTIC_TEMPERATURE : \(characteristic)")
      let copy = UnsafeMutableRawBufferPointer.allocate(byteCount: 2, alignment: MemoryLayout<UInt>.alignment)
      characteristic.value?.copyBytes(to: copy)
      self.temperature = String(copy.load(as: Int16.self))
    }
  }
  
  
}

let UUID_CHARACTERISTIC_BATTERY_LEVEL = CBUUID(string: "00002a19-0000-1000-8000-00805f9b34fb")

let UUID_CHARACTERISTIC_TEMPERATURE = CBUUID(string: "00002a6e-0000-1000-8000-00805f9b34fb")

let UUID_SERVICE_BATTERY = CBUUID(string: "0000180f-0000-1000-8000-00805f9b34fb")

let UUID_SERVICE_ENVIRONMENT_SENSING = CBUUID(string: "0000181a-0000-1000-8000-00805f9b34fb")

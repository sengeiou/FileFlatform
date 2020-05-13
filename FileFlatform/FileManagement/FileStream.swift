//
//  FileStream.swift
//  DocumentListView
//
//  Created by SUNG KIM on 2020/04/13.
//  Copyright © 2020 mcsco. All rights reserved.
//

import Foundation

//euc-kr로 인코딩
let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))

//파일 읽고 저장하는 기능들 모아둠
class FileStream {
  let fixedSize = FixSize()
  
  func int16ToData(value: Int16) -> Data {
    var temp = value
    return Data(bytes: &temp, count: MemoryLayout.size(ofValue: value))
  }
  
  //stirng을 지정한 사이즈의 data로 변환
  func stringToFixSizeData(output_size: Int, str: String) -> [UInt8] {
    var data: [UInt8] = Array(repeating: 0, count: output_size)
    let strToData = str.data(using: encoding) ?? Data()
    var count = 0
    if output_size < strToData.count {
      count = output_size
    } else { count = strToData.count }
    
    for i in 0 ..< count {
      data[i] = strToData[i]
    }
    return data
  }
  
  func readConfigData(url: URL)-> ConfigureData {
    let configData = ConfigureData()
    do {
      let fileHandler = try FileHandle(forReadingFrom: url)
      var fileData = fileHandler.readDataToEndOfFile()
      
      if fileData.count < FixSize().fileSize {
        return configData
      }
      
      var data = fileData.prefix(fixedSize.version)
      var nullIndex = data.firstIndex(of: 0) ?? fixedSize.version
      configData.data[ConfigureType.version.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.version)
      
      data = fileData.prefix(fixedSize.build)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.build
      configData.data[ConfigureType.build.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.build)
      
      fileData = fileData.advanced(by: 28)
      
      data = fileData.prefix(fixedSize.date)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.date
      configData.data[ConfigureType.date.rawValue] = String( data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.date)
      
      data = fileData.prefix(fixedSize.site)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.site
      configData.data[ConfigureType.site.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.site)
      
      data = fileData.prefix(fixedSize.operate)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.operate
      configData.data[ConfigureType.operate.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.operate)
      
      data = fileData.prefix(fixedSize.measuringCo)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.measuringCo
      configData.data[ConfigureType.measuringCO.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.measuringCo)
      
      data = fileData.prefix(fixedSize.object)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.object
      configData.data[ConfigureType.object.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.object)
      
      fileData = fileData.advanced(by: 66)
      
      data = fileData.prefix(fixedSize.coordinateX)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.coordinateX
      configData.data[ConfigureType.coordinateX.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.coordinateX)
      
      data = fileData.prefix(fixedSize.coordinateY)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.coordinateY
      configData.data[ConfigureType.coordinateY.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.coordinateY)
      
      //senser type
      if fileData.prefix(fixedSize.sensorType).first == SensorCode.Wheel.rawValue {
        configData.data[ConfigureType.sensorType.rawValue] = SensorName.Wheel.rawValue
      } else {
        configData.data[ConfigureType.sensorType.rawValue] = SensorName.Rod.rawValue
      }
      fileData = fileData.advanced(by: fixedSize.sensorType)
      
      data = fileData.prefix(fixedSize.grid)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.grid
      configData.data[ConfigureType.grid.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.grid)
      
      fileData = fileData.advanced(by: 11)
      
      data = fileData.prefix(fixedSize.comment)
      nullIndex = data.firstIndex(of: 0) ?? fixedSize.comment
      configData.data[ConfigureType.comment.rawValue] = String(data: data.prefix(nullIndex), encoding: encoding) ?? ""
      fileData = fileData.advanced(by: fixedSize.comment)
      
      fileData = fileData.advanced(by: 20)
      
    } catch {
      print(error.localizedDescription)
    }
    
    return configData
  }
  
  func readAcData(url: URL, configX: Int, configY: Int)-> [Int16] {
    var acData: [Int16] = Array()
    
    do {
      let fileHandler = try FileHandle(forReadingFrom: url)
      var fileData = fileHandler.readDataToEndOfFile()
      
      if fileData.count < FixSize().fileSize {
        return acData
      }
      
      fileData = fileData.advanced(by: fixedSize.configSize)
      
      if configX != 0 && configY != 0 {
        for i in 0..<configY {
          for j in 0..<configX {
            let value = Int16(fileData[i * fixedSize.maxSizeX * 2 + j * 2]) << 8 | Int16(fileData[i * fixedSize.maxSizeX * 2 + j * 2 + 1])
            acData.append(value.bigEndian)
          }
        }
      }
      
    } catch {
      print(error.localizedDescription)
    }
    return acData
  }
  
  func readAcData(url: URL)-> Data {
    var acData: Data = Data()
    
    do {
      let fileHandler = try FileHandle(forReadingFrom: url)
      let fileData = fileHandler.readDataToEndOfFile()
      
      if fileData.count < FixSize().fileSize {
        return acData
      }
      
      acData = fileData.advanced(by: fixedSize.configSize)
      
    } catch {
      print(error.localizedDescription)
    }
    return acData
  }
  
  func writeConfigureData(url: URL, configData: ConfigureData) {
    do {
      //let path = self.selectURL.url!.appendingPathExtension("new")
      try String("").write(to: url, atomically: false, encoding: .utf8)
      let fileWriteHandler = try FileHandle(forWritingTo: url)
      
      var write_data = stringToFixSizeData(output_size: fixedSize.version, str: configData.data[ConfigureType.version.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.build, str: configData.data[ConfigureType.build.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: 28, str: "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.date, str: configData.data[ConfigureType.date.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.site, str: configData.data[ConfigureType.site.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.operate, str: configData.data[ConfigureType.operate.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.measuringCo, str: configData.data[ConfigureType.measuringCO.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.object, str: configData.data[ConfigureType.object.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: 66, str: "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.coordinateX, str: configData.data[ConfigureType.coordinateX.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.coordinateY, str: configData.data[ConfigureType.coordinateY.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      try fileWriteHandler.seekToEnd()
      if configData.data[ConfigureType.sensorType.rawValue] ?? "" == SensorName.Rod.rawValue {
        fileWriteHandler.write(Data(bytes: [SensorCode.Rod.rawValue], count: 1))
      } else {
        fileWriteHandler.write(Data(bytes: [SensorCode.Wheel.rawValue], count: 1))
      }
      
      write_data = stringToFixSizeData(output_size: fixedSize.grid, str: configData.data[ConfigureType.grid.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: 11, str: "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: fixedSize.comment, str: configData.data[ConfigureType.comment.rawValue] ?? "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
      write_data = stringToFixSizeData(output_size: 20, str: "")
      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(Data(write_data))
      
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func writeAcquisitonData(url: URL, acData: [Int16], configX: Int, configY: Int) {
    do {
      let fileWriteHandler = try FileHandle(forWritingTo: url)
      var writeAcData: Data = Data()

      //입력한 Y좌표 수 만큼 데이터 입력
      for i in 0 ..< configY {
        //데이터 삽입 후 빈값 채우기 최대 x=50
        for j in 0 ..< fixedSize.maxSizeX {
          if(j < configX) {
            writeAcData.append(int16ToData(value: acData[i*configX + j]))
          }
          else {
            writeAcData.append(int16ToData(value: Int16.max))
          }
        }
      }
      
      //나머지 Y좌표 수 만큼 빈데이터 입력
      for _ in 0 ..< fixedSize.maxSizeY - configY {
        for _ in 0 ..< fixedSize.maxSizeX {
          writeAcData.append(int16ToData(value: Int16.max))
        }
      }

      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(writeAcData)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  //수정할때 읽었던 5000크기의 취득 데이터를 다시 그대로 씀
  func writeAcquisitonData(url: URL, acData: Data) {
    do {
      let fileWriteHandler = try FileHandle(forWritingTo: url)

      try fileWriteHandler.seekToEnd()
      fileWriteHandler.write(acData)
    } catch {
      print(error.localizedDescription)
    }
  }
  
}

//
//  DatabaseHelper.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI
import SQLite3

class DatabaseHelper {
  let databaseName = "coriDB.sqlite"
  let configTableName = "configData"
  let bluetoothDeviceTableName = "bluetoothDevice"
  let fixedId = "1" //row 첫번째만 사용함으로 1만 조회함
  
  var db: OpaquePointer? = nil
  
  func openDatabase() -> Bool {
    let documentURL = getDocumentDirectory().appendingPathComponent("\(databaseName)", isDirectory: false)
    if sqlite3_open(documentURL.path, &db) == SQLITE_OK {
      print("Successfully opened connection to database at \(databaseName)")
      return true
    } else {
      print("Unable to open database. Verify that you created the directory described " +
        "in the Getting Started section.")
      return false
    }
  }
  
  func createConfigTable() {
    let createTableString = """
    CREATE TABLE IF NOT EXISTS \(configTableName)(
    Id INT PRIMARY KEY NOT NULL,
    \(ConfigureType.version.rawValue) TEXT DEFAULT '',
    \(ConfigureType.build.rawValue) TEXT DEFAULT '',
    \(ConfigureType.date.rawValue) TEXT DEFAULT '',
    \(ConfigureType.site.rawValue) TEXT DEFAULT '',
    \(ConfigureType.operate.rawValue) TEXT DEFAULT '',
    \(ConfigureType.measuringCO.rawValue) TEXT DEFAULT '',
    \(ConfigureType.object.rawValue) TEXT DEFAULT '',
    \(ConfigureType.coordinateX.rawValue) TEXT DEFAULT '',
    \(ConfigureType.coordinateY.rawValue) TEXT DEFAULT '',
    \(ConfigureType.sensorType.rawValue) TEXT DEFAULT '',
    \(ConfigureType.grid.rawValue) TEXT DEFAULT '',
    \(ConfigureType.comment.rawValue) TEXT DEFAULT '')
    """
    // 1
    var createTableStatement: OpaquePointer? = nil
    // 2
    if sqlite3_prepare(self.db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
      // 3
      if sqlite3_step(createTableStatement) == SQLITE_DONE {
        print("Contact table created.")
      } else {
        print("Contact table could not be created.")
      }
    } else {
      print("CREATE TABLE statement could not be prepared.")
    }
    // 4
    sqlite3_finalize(createTableStatement)
  }
  
  func insertConfigRow() {
    var insertStatement: OpaquePointer? = nil
    
    let insertStatementString = """
    INSERT INTO \(configTableName)
    (Id)
    VALUES
    (\(fixedId))
    """
    
    if sqlite3_prepare(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
      if sqlite3_step(insertStatement) == SQLITE_DONE {
        print("Successfully inserted row.")
      } else {
        print("Could not insert row.")
      }
    } else {
      print("INSERT statement could not be prepared.")
    }
    sqlite3_finalize(insertStatement)
  }
  
  func updateConfigRow(column: String, value: String) {
    var updateStatement: OpaquePointer? = nil
    
    let updateStatementString = "UPDATE \(configTableName) SET \(column) = '\(value)' WHERE Id = \(fixedId)"
    
    if sqlite3_prepare(db, updateStatementString, -1, &updateStatement, nil) ==
      SQLITE_OK {
      if sqlite3_step(updateStatement) == SQLITE_DONE {
        print("\nSuccessfully updated row.")
      } else {
        print("\nCould not update row.")
      }
    } else {
      print("\nUPDATE statement is not prepared")
    }
    sqlite3_finalize(updateStatement)
  }
  
  func readConfigRow()-> ConfigureData {
    let configData = ConfigureData()
    var queryStatement: OpaquePointer?
    let queryStatementString = "SELECT * FROM \(configTableName)"
    // 1
    if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
      // 2
      if sqlite3_step(queryStatement) == SQLITE_ROW {
        var columnIndex: Int32 = 1
        for column in ConfigureType.allCases {
          configData.data[column.rawValue] = String(cString: sqlite3_column_text(queryStatement, columnIndex))
          columnIndex += 1
        }
      }
    } else {
      let errorMessage = String(cString: sqlite3_errmsg(db))
      print("\nQuery is not prepared \(errorMessage)")
    }
    sqlite3_finalize(queryStatement)
    return configData
  }
  
  func createBluetoothDeviceTable() {
    let createTableString = """
    CREATE TABLE IF NOT EXISTS \(bluetoothDeviceTableName)(
    Id INT PRIMARY KEY NOT NULL,
    \(BluetoothDeviceType.name.rawValue) TEXT DEFAULT '',
    \(BluetoothDeviceType.uuid.rawValue) TEXT DEFAULT '')
    """
    // 1
    var createTableStatement: OpaquePointer? = nil
    // 2
    if sqlite3_prepare(self.db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
      // 3
      if sqlite3_step(createTableStatement) == SQLITE_DONE {
        print("Contact table created.")
      } else {
        print("Contact table could not be created.")
      }
    } else {
      print("CREATE TABLE statement could not be prepared.")
    }
    // 4
    sqlite3_finalize(createTableStatement)
  }
  
  func insertBluetoothDeviceRow() {
    var insertStatement: OpaquePointer? = nil
    
    let insertStatementString = """
    INSERT INTO \(bluetoothDeviceTableName)
    (Id)
    VALUES
    (\(fixedId))
    """
    
    if sqlite3_prepare(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
      if sqlite3_step(insertStatement) == SQLITE_DONE {
        print("Successfully inserted row.")
      } else {
        print("Could not insert row.")
      }
    } else {
      print("INSERT statement could not be prepared.")
    }
    sqlite3_finalize(insertStatement)
  }
  
  func updateBluetoothDeviceRow(column: String, value: String) {
    var updateStatement: OpaquePointer? = nil
    
    let updateStatementString = "UPDATE \(bluetoothDeviceTableName) SET \(column) = '\(value)' WHERE Id = \(fixedId)"
    
    if sqlite3_prepare(db, updateStatementString, -1, &updateStatement, nil) ==
      SQLITE_OK {
      if sqlite3_step(updateStatement) == SQLITE_DONE {
        print("\nSuccessfully updated row.")
      } else {
        print("\nCould not update row.")
      }
    } else {
      print("\nUPDATE statement is not prepared")
    }
    sqlite3_finalize(updateStatement)
  }
  
  func readBluetoothDeviceUUID()-> String {
    var uuid: String = ""
    var queryStatement: OpaquePointer?
    let queryStatementString = "SELECT * FROM \(bluetoothDeviceTableName)"
    // 1
    if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
      // name, uuid 중에 uuid만 필요함으로 해당 칼럼만 가져옴
      if sqlite3_step(queryStatement) == SQLITE_ROW {
        let columnIndex: Int32 = 2
        uuid = String(cString: sqlite3_column_text(queryStatement, columnIndex))
      }
    } else {
      let errorMessage = String(cString: sqlite3_errmsg(db))
      print("\nQuery is not prepared \(errorMessage)")
    }
    sqlite3_finalize(queryStatement)
    return uuid
  }
}

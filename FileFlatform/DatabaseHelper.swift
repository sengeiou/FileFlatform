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
  let tableName = "configData"
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
  
  func createTable() {
    let createTableString = """
    CREATE TABLE IF NOT EXISTS \(tableName)(
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
    INSERT INTO \(tableName)
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
    
    let updateStatementString = "UPDATE \(tableName) SET \(column) = '\(value)' WHERE Id = \(fixedId)"
    
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
  
  func selectConfigRow()-> ConfigureData {
    var configData = ConfigureData()
    var queryStatement: OpaquePointer?
    let queryStatementString = "SELECT * FROM \(tableName)"
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
}

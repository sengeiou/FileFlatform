//
//  FileManagement.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

var pickerURLs: [URL] = []

//앱의 기본 document 경로
func getDocumentDirectory() -> URL {
  let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
  
  return paths[0]
}

//경로에 있는 모든 파일의 경로를 가져옴
func getChildFromDirectory(url: URL) -> [URL] {
  do {
    return try FileManager().contentsOfDirectory(at: url, includingPropertiesForKeys: nil )
  } catch {
    print(error.localizedDescription)
    return []
  }
}

//경로에 파일 상태 체크 파일,디렉토리,무언가
extension URL {
  enum Filestatus {
    case isFile
    case isDir
    case isNot
  }
  
  var filestatus: Filestatus {
    get {
      let filestatus: Filestatus
      var isDir: ObjCBool = false
      if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir) {
        if isDir.boolValue {
          // file exists and is a directory
          filestatus = .isDir
        }
        else {
          // file exists and is not a directory
          filestatus = .isFile
        }
      }
      else {
        // file does not exist
        filestatus = .isNot
      }
      return filestatus
    }
  }
}



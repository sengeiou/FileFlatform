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
    var urls = try FileManager().contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    
    urls.sort {
      do {
        let attributes1  = try FileManager().attributesOfItem(atPath: $0.path)
        let attributes2  = try FileManager().attributesOfItem(atPath: $1.path)
        
        let date1: Date = attributes1[FileAttributeKey.modificationDate] as! Date
        let date2: Date = attributes2[FileAttributeKey.modificationDate] as! Date
        return date1 > date2
      } catch {
        print(error.localizedDescription)
        return true
      }
    }
    
    return urls
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

//외부로 파일 보낼때
struct ExportImageView: View {
  @State var showExportFile = false
  var url: URL
  @Binding var presentURL: URL
  @Binding var urlList: [URL]
  
  var body: some View {
    Image(systemName: "tray.and.arrow.up")
      .onTapGesture {
        self.showExportFile = true}
      .sheet(
        isPresented: $showExportFile,
        onDismiss: { print("Dismiss") },
        content: { ActivityViewController(activityItems: [self.url])
          .onDisappear() {
            self.urlList = getChildFromDirectory(url: self.presentURL)
          }
      })
  }
}

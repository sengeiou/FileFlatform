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

//apple에서 지원하는 파일을 선택할때 ui
struct DocumentPickerViewController {
  //private let supportedTypes: [String] = ["public.image", "public.txt"]
  // Callback to be executed when users close the document picker.
  //private let onDismiss: () -> Void
  private let documentPicker: () -> Void
  //    init(onDismiss: @escaping () -> Void) {
  //        self.onDismiss = onDismiss
  //    }
  init(documentPicker: @escaping () -> Void) {
    self.documentPicker = documentPicker
  }
}

// MARK: - UIViewControllerRepresentable
//apple에서 지원하는 파일을 선택할때 ui
extension DocumentPickerViewController: UIViewControllerRepresentable {
  
  typealias UIViewControllerType = UIDocumentPickerViewController
  
  func makeUIViewController(context: Context) -> DocumentPickerViewController.UIViewControllerType {
    let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
    documentPickerController.allowsMultipleSelection = true
    documentPickerController.delegate = context.coordinator
    return documentPickerController
  }
  
  func updateUIViewController(_ uiViewController: DocumentPickerViewController.UIViewControllerType, context: Context) {}
  
  // MARK: Coordinator
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIDocumentPickerDelegate {
    var parent: DocumentPickerViewController
    
    init(_ documentPickerController: DocumentPickerViewController) {
      parent = documentPickerController
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      // TODO: handle user selection
      pickerURLs = urls
      parent.documentPicker()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      //parent.onDismiss()
    }
  }
}

//apple에서 지원하는 외부로 파일을 내보낼때 ui
struct ActivityViewController: UIViewControllerRepresentable {
  
  var activityItems: [Any]
  var applicationActivities: [UIActivity]? = nil
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}


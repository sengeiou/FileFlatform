//
//  DocumentPickerViewcontroller.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/11.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

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

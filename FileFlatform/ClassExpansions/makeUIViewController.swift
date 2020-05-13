//
//  ActivityViewController.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/11.
//  Copyright © 2020 mcsco. All rights reserved.
//
import SwiftUI

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

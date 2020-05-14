//
//  ContentView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/14.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State var showLinkViews: Bool = false
  @State var showingAboutAlert: Bool = false
  
  //titlebar 색상 초기화를 위해 넣음..
  init() {
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithTransparentBackground()
    coloredAppearance.backgroundColor = backgroundColor
    coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    
    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = .white
  }

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ZStack{
          Image("main")
            .resizable()
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .scaledToFill()
          
          VStack(alignment: .center, spacing: 0) {
            //위에 공백 주기
            Rectangle()
              .opacity(0)
              .frame(height: geometry.size.height*0.45)
            
            NavigationLink(destination: ConfigurationView(showConfig: self.$showLinkViews, editedConfigure: {}, viewMode: .constant(.input), editURL: .constant(URL(fileURLWithPath: ""))), isActive: self.$showLinkViews) {
              MainButtonView(title: "DATA ACQUISITION", image: "acquisition")
            }
            .isDetailLink(false)
            NavigationLink(destination: FileManagementView()) {
              MainButtonView(title: "FILE MANAGEMENT", image: "filemanagement")
            }
            
            Button(action: {
              self.showingAboutAlert = true
            }, label: {
              MainButtonView(title: "ABOUT", image: "about-b")
            })
            
            //하단 공백 주기
            Rectangle()
              .opacity(0)
              .frame(height: geometry.size.height*0.15)
          }
        }
      }
      .navigationBarTitle("", displayMode: .inline)
      .aboutAlert(isShowing: self.$showingAboutAlert)

    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}



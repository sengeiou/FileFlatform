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
  
  let buttonBackgroundColor: Color = Color(red: 28/255, green: 125/255, blue: 197/255)
      
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
              .frame(height: geometry.size.height*0.25)
            
            NavigationLink(destination: ConfigurationView(showConfig: self.$showLinkViews, editedConfigure: {}, viewMode: .constant(.input), editURL: .constant(URL(fileURLWithPath: ""))), isActive: self.$showLinkViews) {
              HStack(alignment: .center, spacing: 0){
                Image(systemName: "link")
                  .imageScale(.large)
                  .padding(.leading, 10)
                  .foregroundColor(Color.white)
                Text("DATA ACQUISITION")
                  .frame(width: geometry.size.width * 0.6 - 40, alignment: .center)
                  .foregroundColor(Color.white)
              }
              .frame(width: geometry.size.width * 0.6, height: 50)
              .background(self.buttonBackgroundColor)
              .cornerRadius(10)
              .padding(.bottom, 20)
            }
            .isDetailLink(false)
            NavigationLink(destination: FileManagementView()) {
              HStack(alignment: .center, spacing: 0){
                Image(systemName: "folder")
                  .imageScale(.large)
                  .padding(.leading, 10)
                  .foregroundColor(Color.white)
                Text("FILE MANAGEMENT")
                  .frame(width: geometry.size.width * 0.6 - 40, alignment: .center)
                  .foregroundColor(Color.white)
              }
              .frame(width: geometry.size.width * 0.6, height: 50)
              .background(self.buttonBackgroundColor)
              .cornerRadius(10)
              .padding(.bottom, 20)
            }
            
            Button(action: {
              self.showingAboutAlert = true
            }, label: {
              HStack(alignment: .center, spacing: 0){
                Image(systemName: "ellipsis.circle")
                  .imageScale(.large)
                  .padding(.leading, 10)
                  .foregroundColor(Color.white)
                Text("ABOUT")
                  .frame(width: geometry.size.width * 0.6 - 40, alignment: .center)
                  .foregroundColor(Color.white)
              }
              .frame(width: geometry.size.width * 0.6, height: 50)
              .background(self.buttonBackgroundColor)
              .cornerRadius(10)
            })
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



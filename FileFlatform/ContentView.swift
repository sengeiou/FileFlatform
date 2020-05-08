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
  
  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ZStack{
          Image("main")
            .resizable()
            
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .scaledToFill()
          
          VStack(alignment: .center, spacing: 0) {
            
            NavigationLink(destination: ConfigurationView(showConfig: self.$showLinkViews, editedConfigure: {}, viewMode: .constant(.input), editURL: .constant(URL(fileURLWithPath: ""))), isActive: self.$showLinkViews) {
              Text("DATA ACQUISITION")
                .frame(width: geometry.size.width / 1.4, height: 60)
                .background(Color.yellow)
                .cornerRadius(20)
                .padding(.bottom, 20)
            }
            .isDetailLink(false)
            NavigationLink(destination: FileManagementView()) {
              Text("FILE MANAGEMENT")
                .frame(width: geometry.size.width / 1.4, height: 60)
                .background(Color.yellow)
                .cornerRadius(20)
                .padding(.bottom, 20)
            }
            
            Button(action: {
              self.showingAboutAlert = true
            }, label: {
              Text("ABOUT")
                .frame(width: geometry.size.width / 1.4, height: 60)
                .background(Color.yellow)
                .cornerRadius(20)
            })
          }
          .frame(width: geometry.size.width, height: geometry.size.height*0.7, alignment: .bottom)
        }
      }
      .navigationBarTitle("Main", displayMode: .inline)
      .textFieldAlert(isShowing: self.$showingAboutAlert)
      
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct AboutAlert<Presenting>: View where Presenting: View {
  @Binding var isShowing: Bool
  let version: String = "CORI.1.00"
  let build: String = "May152010"
  let presenting: Presenting
  let title: String = "CORI Information"
  
  var body: some View {
    GeometryReader{ geometry in
      ZStack {
        self.presenting
          .disabled(self.isShowing)
          .onTapGesture { self.isShowing = false }
       
        VStack(alignment: .center, spacing: 1) {
          Text(self.title)
            .foregroundColor(Color.black)
            .padding(.all, 5)
          Image("about")
            .resizable()
            .frame(width: 300, height: 150, alignment: .center)
          Text("Version : \(self.version)")
            .foregroundColor(Color.black)
          Text("Build : \(self.build)")
            .foregroundColor(Color.black)
        }
        .frame(width: 300)
        .background(Color.gray)
        .opacity(self.isShowing ? 1 : 0)
        .cornerRadius(10)
      }
    }
  }
}

extension View {
  func textFieldAlert(isShowing: Binding<Bool>) -> some View {
    AboutAlert(isShowing: isShowing,
               presenting: self)
  }
  
}


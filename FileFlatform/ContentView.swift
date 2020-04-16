//
//  ContentView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/14.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State var showConfig: Bool = false
  
  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ZStack{
          Image("mainImage")
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .scaledToFill()
          
          VStack {
            NavigationLink(destination: ConfigurationView(showConfig: self.$showConfig), isActive: self.$showConfig) {
              Text("DATA ACQUISITION")
                .frame(width: geometry.size.width / 1.4, height: 60)
                .background(Color.yellow)
                .cornerRadius(20)
                .padding()
            }
            .isDetailLink(false)
            NavigationLink(destination: FileManagementView()) {
              Text("FILE MANAGEMENT")
                .frame(width: geometry.size.width / 1.4, height: 60)
                .background(Color.yellow)
                .cornerRadius(20)
                .padding()
            }
            NavigationLink(destination: EmptyView()) {
              Text("ABOUT")
                .frame(width: geometry.size.width / 1.4, height: 60)
                .background(Color.yellow)
                .cornerRadius(20)
                .padding()
            }
          }
          .frame(width: geometry.size.width, height: geometry.size.height/1.2, alignment: .bottom)
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MainButton<Content: View>: View {
  var title: String
  var view: Content
  
  var body: some View {
    GeometryReader { geometry in
      NavigationLink(destination: self.view, label: {
        Text("\(self.title)")
          .font(.title)
          .foregroundColor(.white)
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
          .background(Color.red)
          .cornerRadius(20)
      })
    }
    .padding(.horizontal)
    .padding(.top)
  }
}

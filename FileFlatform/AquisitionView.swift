//
//  AquisitionView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/15.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct AquisitionView: View {
  @Binding var showConfig: Bool //main 화면으로 바로 복귀하기 위해서
  @State var count: Int =  1
  @State var selectSaveURL: URL = getDocumentDirectory()
  @State var showSaveDirectory: Bool = false
  @State private var fileName: String = "TemporaryName.SCM"
  
  var btnBack : some View {
    HStack {
      Button(action: { self.showConfig = false }) {
        Text("Done")
      }
    }
  }
  
  var saveView : some View {
    HStack {
      Image(systemName: "tray.and.arrow.down")
        .imageScale(.large)
        .onTapGesture {
          self.showSaveDirectory = true
      }
    }
  }
  
  var body: some View {
    VStack {
      Button(action: {
        
        self.showSaveDirectory = true
        
      }, label: {Text("\(count)")})
      Button(action: {self.count = self.count+1}, label: {Text("ABC")})
      
      
      NavigationLink(destination: SaveDirectoryView(selectSaveURL: self.$selectSaveURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showSaveDirectory, fileName: self.$fileName, seletionPicker: {
        
        let acData: [Int16] = Array() //나중에는 실제 취득데이타
        
        let dbHelper = DatabaseHelper()
        if dbHelper.openDatabase() {
          let configData = dbHelper.selectConfigRow()
          let fileStream = FileStream()
          fileStream.writeConfigureData(url: self.selectSaveURL, configData: configData, acData: acData)
        }
      }), isActive: self.$showSaveDirectory, label: {EmptyView()}).hidden()
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarItems(leading: btnBack, trailing: saveView)
    .navigationBarTitle("Acquisiton")
    
  }
}

struct AquisitionView_Previews: PreviewProvider {
    static var previews: some View {
      AquisitionView(showConfig: .constant(true))
    }
}

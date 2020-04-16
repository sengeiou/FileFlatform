//
//  FileManagementView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct FileManagementView: View {
  @State var showLoadDirectory: Bool = false
  @State var selectLoadURL: URL = getDocumentDirectory()
  @State var configData = ConfigureData()
  
  var loadView : some View {
    HStack {
      Image(systemName: "tray.and.arrow.up")
        .imageScale(.large)
        .onTapGesture {
          self.showLoadDirectory = true
      }
    }
  }
  
  var body: some View {
    VStack {
      Text(self.configData.data.description)
        .navigationBarItems(trailing: loadView)
        .navigationBarTitle("FileManagement", displayMode: .inline)
      
      
      NavigationLink(destination: LoadDirectoryView(selectLoadURL: self.$selectLoadURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showLoadDirectory, seletionPicker: {
        //리드하는곳, 여기서 다 읽으면 될듯 ㅠㅠ
        let fileStream = FileStream()
        self.configData = fileStream.readConfigData(url: self.selectLoadURL)
      }), isActive: self.$showLoadDirectory, label: {EmptyView()}).hidden()
    }
  }
}

struct FileManagementView_Previews: PreviewProvider {
  static var previews: some View {
    FileManagementView()
  }
}

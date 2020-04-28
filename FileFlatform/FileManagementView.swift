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
  
  //@State var gridConfig: ConfigDataForGrid //좌표뷰에 사용되는 데이터들
  @State var extractedGridView: AcquisitionGridView = AcquisitionGridView(config: ConfigDataForGrid(configX: 0, configY: 0))
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
      
      
      extractedGridView
      
      
      //navigationBatItem에서 load를 클릭했을때 보여주는 화면
      NavigationLink(destination: LoadDirectoryView(selectLoadURL: self.$selectLoadURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showLoadDirectory, seletionPicker: {
        //리드하는곳, 여기서 다 읽으면 될듯 ㅠㅠ
        let fileStream = FileStream()
        self.configData = fileStream.readConfigData(url: self.selectLoadURL)
        
        
        //설정한 x,y 좌표 읽기
        let configX = Int(self.configData.data[ConfigureType.coordinateX.rawValue] ?? "0")!
        let configY = Int(self.configData.data[ConfigureType.coordinateY.rawValue] ?? "0")!
        let acData = fileStream.readAcData(url: self.selectLoadURL, configX: configX, configY: configY)

        //1.GridView에 넣어줄 정보에 좌표 세팅
        let setGridConfig = ConfigDataForGrid(configX: configX, configY: configY)
        //2.세팅한 정보에 Acquisition 정보 세팅
        setGridConfig.cells = acData.map( { value in value == Int16.max ? CellProperty(acData: "", color: setGridConfig.initCellColor) : CellProperty(acData: String(value), color: getRGB(acData: value)) })
        
        
        CaculateGradation(gridConfig: setGridConfig)
        
        //3.뷰 생성 및 대입
        self.extractedGridView = AcquisitionGridView(config: setGridConfig)
        
        
        
        
        
//        //설정한 x,y 좌표 읽기
//        let configX = Int(self.configData.data[ConfigureType.coordinateX.rawValue] ?? "0")!
//        let configY = Int(self.configData.data[ConfigureType.coordinateY.rawValue] ?? "0")!
//        let acData = fileStream.readAcData(url: self.selectLoadURL, configX: configX, configY: configY)
//
//        //1.GridView에 넣어줄 정보에 좌표 세팅
//        let setGridConfig = ConfigDataForGrid(configX: configX, configY: configY)
//        //2.세팅한 정보에 Acquisition 정보 세팅
//        setGridConfig.cells = acData.map( { value in value == Int16.max ? CellProperty(acData: "", color: setGridConfig.initCellColor) : CellProperty(acData: String(value), color: getRGB(acData: value)) })
//        //3.뷰 생성 및 대입
//        self.extractedGridView = AcquisitionGridView(config: setGridConfig)
      }), isActive: self.$showLoadDirectory, label: {EmptyView()}).hidden()
    }
    .navigationBarItems(trailing: loadView)
    .navigationBarTitle("FileManagement", displayMode: .inline)
  }
}

struct FileManagementView_Previews: PreviewProvider {
  static var previews: some View {
    FileManagementView()
  }
}

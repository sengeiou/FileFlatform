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
  @State var contourViewSize: CGRect = .zero
  @State var viewChange: GridViewMod = .text
  //@State var gridConfig: ConfigDataForGrid //좌표뷰에 사용되는 데이터들
  @State var gridView: AcquisitionGridView = AcquisitionGridView(config: ConfigDataForGrid(configX: 0, configY: 0))
  
  @State var contourGridView: ContourGridView = ContourGridView(config: ConfigDataForGrid(configX: 5, configY: 5), image: .constant(Image(systemName: "hare.fill")))
  
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
      
      ZStack{
        if self.viewChange == .contour {
          contourGridView
        } else {
          gridView
        }
      }.overlay(Color.clear.modifier(GeometryGetterMod(rect: self.$contourViewSize)))
      
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
        //2.해당 셀 색상 값 설정
        setGridConfig.cells = acData.map( { value in value == Int16.max ? CellProperty(acData: "", color: setGridConfig.initCellColor) : CellProperty(acData: String(value), color: getRGB(acData: value)) })
        
        //3.그라데이션 값 계산
        setGridConfig.CaculateGradation()
        setGridConfig.readMode = true
        //4.뷰 생성 및 대입
        self.gridView = AcquisitionGridView(config: setGridConfig)
        
        //contour 계산
        let path = getContourPath(
          width: self.contourViewSize.width,
          height: self.contourViewSize.height,
        configX: setGridConfig.configX,
        configY: setGridConfig.configY,
        acData: setGridConfig.cells.map({$0.acData}))
        
        //이미지 생성 및 대입
        let image = Image(uiImage: ContourView(path: path, width: self.contourViewSize.width, hegiht: self.contourViewSize.height).asImage())
        self.contourGridView = ContourGridView(config: setGridConfig, image: .constant(image))
        
      }), isActive: self.$showLoadDirectory, label: {EmptyView()}).hidden()
      
      Button(action: {
        if self.viewChange == .text {
          self.gridView.config.gradationOption = true
          self.viewChange = .gradation
        } else if self.viewChange == .gradation {
          self.gridView.config.gradationOption = false
          self.viewChange = .contour
        } else {
          self.viewChange = .text
        }
      }, label: {
        Text("ChangeView").font(.title)
      })
    }
    .navigationBarItems(trailing: loadView)
    .navigationBarTitle("FileManagement", displayMode: .inline)
  }
}

struct GeometryGetterMod: ViewModifier {

    @Binding var rect: CGRect

    func body(content: Content) -> some View {
        print(content)
        return GeometryReader { (g) -> Color in // (g) -> Content in - is what it could be, but it doesn't work
            DispatchQueue.main.async { // to avoid warning
                self.rect = g.frame(in: .global)
            }
            return Color.clear // return content - doesn't work
        }
    }
}

struct FileManagementView_Previews: PreviewProvider {
  static var previews: some View {
    FileManagementView()
  }
}

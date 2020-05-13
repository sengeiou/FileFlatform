//
//  FileManagementView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct FileManagementView: View {
  @State var showLoadDirectory: Bool = false //파일을 불러올때
  @State var showSetConfigView: Bool = false //csv파일을 저장할때
  @State var showAlertDoNotFileSlect: Bool = false //선택한 파일 없이 관련 기능을 사용할때
  @State var selectLoadURL: URL = getDocumentDirectory() //저장시 선택한 url
  @State var viewChange: GridViewMod = .text //취득 데이터를 보여주는 모드
  
  //csv파일 저장 시 사용되는 변수들
  @State private var csvFileName: String = "TemporaryName.csv" 
  @State var showSaveDirectory: Bool = false // save 경로선택 화면
  @State var selectSaveURL: URL = getDocumentDirectory() //save화면에서 선택한 저장경로
  
  //읽은 파일의 데이타정보
  @State var configData = ConfigureData()
  @State var acData: [Int16] = []
  @State var configX = 0 //configData에 있는 정보지만 쓸때마다 데이터형 변환을 해야 해서 뺌
  @State var configY = 0
  
  //contour이미지가 그려지는 공간
  @State var contourViewSize: CGRect = .zero
  
  //취득 데이터를 표시하는 뷰(텍스트, 그라데이션 모드)
  @State var gridView: AcquisitionGridView = AcquisitionGridView(config: ConfigDataForGrid(configX: 0, configY: 0))
  //취득 데이터를 표시하는 등고선뷰
  @State var contourGridView: ContourGridView = ContourGridView(config: ConfigDataForGrid(configX: 0, configY: 0), contourImage: Image(systemName: "hare"))
  
  //상단에 간단하게 설정 정보를 보여주는 뷰
  @State var configSummaryView: ConfigureSummaryView = ConfigureSummaryView()
  
  //오른쪽 타이틀바 아이콘
  var rightBarIcons : some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Button(action: {
        if self.configData.fileName.isEmpty {
          self.showAlertDoNotFileSlect = true
        } else {
          self.showSetConfigView = true
        }
      }, label: {
        Image(systemName: "pencil")
          .frame(width: 30, height: 30, alignment: .center)
      })
      
      Button(action: {
        if self.configData.fileName.isEmpty {
          self.showAlertDoNotFileSlect = true
        } else {
          //확장자 체크하여 scm일 경우에만 확장자를 csv로 교체하고 아니면 csv를 그냥 추가
          let components = self.configData.fileName.components(separatedBy: ".")
          if components[components.count - 1].lowercased() == "scm" {
            self.csvFileName = components[0]
            for index in 1..<components.count-1 {
              self.csvFileName.append(".\(components[index])")
            }
          }
          self.csvFileName.append(".csv")
          
          self.showSaveDirectory = true
        }
      }, label: {
        Image(systemName: "doc")
          .frame(width: 30, height: 30, alignment: .center)
      })
      
      Button(action: {self.showLoadDirectory = true}, label: {
        Image(systemName: "tray.and.arrow.up")
          .frame(width: 30, height: 30, alignment: .center)
      })
    }
  }
  
  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      configSummaryView
      
      ZStack{
        if self.viewChange == .contour {
          contourGridView
        } else {
          gridView
        }
      }.overlay(Color.clear.modifier(GeometryGetterMod(rect: self.$contourViewSize)))
      
      //navigationBatItem에서 load를 클릭했을때 보여주는 화면
      NavigationLink(destination: LoadDirectoryView(selectLoadURL: self.$selectLoadURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showLoadDirectory, seletionPicker: { self.reDrawGridView() }), isActive: self.$showLoadDirectory, label: {EmptyView()}).hidden()
      
      NavigationLink(destination: ConfigurationView(showConfig: self.$showSetConfigView, editedConfigure: { self.reDrawGridView() }, viewMode: .constant(.edit), editURL: self.$selectLoadURL), isActive: self.$showSetConfigView, label: {EmptyView()}).hidden()
      
      GradationExampleView()
      
      UnderButtonView(title: "ChangeView", clickEvent: {
        if self.viewChange == .text {
          self.gridView.config.gradationOption = true
          self.viewChange = .gradation
        } else if self.viewChange == .gradation {
          self.gridView.config.gradationOption = false
          self.viewChange = .contour
        } else {
          self.viewChange = .text
        }})
      
      
      //저장시 열리는 네비게이션창
      NavigationLink(destination: SaveDirectoryView(selectSaveURL: self.$selectSaveURL, presentURL: .constant(getDocumentDirectory()), showSelf: self.$showSaveDirectory, fileName: self.$csvFileName, extention: .constant("csv"), seletionPicker: {self.createCSV()}), isActive: self.$showSaveDirectory, label: {EmptyView()})
    }
    .navigationBarItems(trailing: rightBarIcons)
    .navigationBarTitle("FileManagement", displayMode: .inline)
    .alert(isPresented: self.$showAlertDoNotFileSlect) {
      Alert(title: Text("Please open the file first"))
    }
  }
  
  //파일을 로드했을때 거기에 맞게 다시 그리기
  func reDrawGridView() {
    //리드하는곳, 여기서 다 읽으면 될듯 ㅠㅠ
    let fileStream = FileStream()
    self.configData = fileStream.readConfigData(url: self.selectLoadURL)
    self.configData.fileName = self.selectLoadURL.lastPathComponent
    
    //설정한 x,y 좌표 읽기
    self.configX = Int(self.configData.data[ConfigureType.coordinateX.rawValue] ?? "0") ?? 0
    self.configY = Int(self.configData.data[ConfigureType.coordinateY.rawValue] ?? "0") ?? 0
    self.acData = fileStream.readAcData(url: self.selectLoadURL, configX: configX, configY: configY)
    
    //1.GridView에 넣어줄 정보에 좌표 세팅
    let setGridConfig = ConfigDataForGrid(configX: configX, configY: configY)
    //2.해당 셀 색상 값 설정
    setGridConfig.cells = self.acData.map( { value in value == Int16.max ? CellProperty(acData: "", color: setGridConfig.initCellColor) : CellProperty(acData: String(value), color: getRGB(acData: value)) })
    
    //3.그라데이션 값 계산
    setGridConfig.CaculateGradation()
    setGridConfig.readMode = true
    setGridConfig.gradationOption = self.gridView.config.gradationOption
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
    self.contourGridView = ContourGridView(config: setGridConfig,  contourImage: image)
    
    self.configSummaryView.configData = self.configData
  }
  
  
  func createCSV() {
    var csvText = "Y\\X"
    let fixSize = FixSize()
    let configTypes = ConfigureType.allCases
    var configTypeIndex = 2 //version이랑 build정보는 뺌
    
    //x좌표 첫줄 생성
    for x in 0..<fixSize.fixSizeX {
      csvText.append(",\(x+1)")
    }
    csvText.append("\n")
    
    //총 10x12 표를 생성
    for indexY in 0..<fixSize.fixSizeY {
      csvText.append("\(indexY+1)")
      for indexX in 0..<fixSize.fixSizeX {
        //취득 데이타가 있다면 데이타 아니면 공백
        if (indexY < configY && indexX < configX) {
          let data = self.acData[indexY * configX + indexX]
          if data == Int16.max {
            csvText.append(",")
          } else {
            let acData = String(self.acData[indexY * configX + indexX])
            csvText.append(",\(acData)")
          }
        } else {
          csvText.append(",")
        }
      }
      
      //취득데이타 표 옆에 config정보 하나씩 씀 총 10개
      if configTypes.count > configTypeIndex {
        let title = configTypes[configTypeIndex].rawValue
        csvText.append(",,\(title)")
        csvText.append(",\(self.configData.data[title] ?? "")")
        configTypeIndex += 1
      }
      csvText.append("\n")
    }
    
    do {
      try csvText.write(to: self.selectSaveURL as URL, atomically: true, encoding: encoding)
      print("Saved to create csv file")
    } catch {
      print("Failed to create csv file")
      print("\(error)")
    }
  }
}

//Contour 이미지를 나타내기 위해
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
    ConfigureSummaryView()
  }
}

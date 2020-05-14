//
//  SaveDirectoryView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI
import Combine

//파일을 저장할때 디렉토리 및 파일 이름을 정할 수 있는 창
struct SaveDirectoryView_Previews: PreviewProvider {
  static var previews: some View {
    SaveDirectoryView(selectSaveURL: .constant(getDocumentDirectory()), presentURL: .constant(getDocumentDirectory()), showSelf: .constant(true), fileName: .constant("temp.scm"), extention: .constant(".scm"),seletionPicker: {}, scmSaveMode: false)
  }
}


struct SaveDirectoryView: View {
  @EnvironmentObject var keyboard: KeyboardResponder
  @Binding var selectSaveURL: URL //실제 저장할 파일 경로
  @Binding var presentURL: URL //리스트에 보여지고 있는 경로
  @Binding var showSelf: Bool //네비게이션 뷰를 한번에 닫기 위해
  @Binding var fileName: String //유저가 입력하는 파일 이름
  @Binding var extention: String
  @State var showAlertFileExist: Bool = false //저장 경로 선택 시 파일이 존재할때
  @State var showAlertFolderError: Bool = false //저장 경로 선택 시 폴더가 존재할때
  @State var messageFolderError: String = ""
  private var seletionPicker: () -> Void //선택한 파일경로로 외부에서 처리하기 위해 호출하는 함수
  @State private var urlList: [URL] //리스트 삭제 시 갱신이 안되어 따로 처리.
  
  var scmSaveMode: Bool = false //cvs파일 저장후 바로 창이 안 닫히게 하기 위해 ㅠ
  
  //폴더 이름 입력하는 창 관련 변수
  @State var createFolderName: String = ""
  @State var showCreateFolder: Bool = false
  
  init(selectSaveURL: Binding<URL>, presentURL: Binding<URL>, showSelf: Binding<Bool>, fileName: Binding<String>, extention: Binding<String>, seletionPicker: @escaping () -> Void, scmSaveMode: Bool) {
    self.seletionPicker = seletionPicker
    self._selectSaveURL = selectSaveURL
    self._presentURL = presentURL
    self._showSelf = showSelf
    self._fileName = fileName
    self._extention = extention
    self._urlList = State.init(wrappedValue: getChildFromDirectory(url: presentURL.wrappedValue))
    self.scmSaveMode = scmSaveMode
  }
  
  //오른쪽 타이틀바 아이콘
  var rightBarIcons : some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Button(action: {
        self.inputDirectoryNameDialog()
      }, label: {
        Image(systemName: "folder.badge.plus")
          .frame(width: 30, height: 30, alignment: .center)
      })
        .alert(isPresented: self.$showAlertFolderError, content: {
          Alert(title: Text("\(self.messageFolderError)"))
        })
    }
  }
  
  var body: some View {
    VStack {
      //현재 디렉토리의 파일리스트
      List {
        //파일이라면
        ForEach(self.urlList, id: \.self){ url in
          Group {
            if url.filestatus == URL.Filestatus.isFile {
              if url.lastPathComponent.lowercased().components(separatedBy: self.extention).count > 1{
                HStack {
                  Image(systemName: "doc.text.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
  
                  Button(action: {
                    self.fileName = url.lastPathComponent
                  }, label: {Text("\(url.lastPathComponent)")} )
                  
                  
                  Spacer()
                  
                  if !self.scmSaveMode {
                    ExportImageView(url: url, presentURL: self.$presentURL, urlList: self.$urlList)
                  }
                }
              }
            }
          }
        }.onDelete(perform: deleteRow)
        
        //파일이 아닌 폴더라면
        ForEach(self.urlList, id: \.self){ url in
          Group {
            if url.filestatus != URL.Filestatus.isFile {
              //파일이 아니면 폴더라고 처리하고 링크로 만듬
              NavigationLink(
                destination:
                SaveDirectoryView (selectSaveURL: self.$selectSaveURL,
                                   presentURL: .constant(url),
                                   showSelf: self.$showSelf,
                                   fileName: self.$fileName, extention: self.$extention, seletionPicker: self.seletionPicker, scmSaveMode: self.scmSaveMode)
                  .navigationBarTitle("\(url.lastPathComponent)"),
                label: {
                  HStack {
                    Image(systemName: "folder.fill")
                      .imageScale(.large)
                      .foregroundColor(.yellow)
                    
                    Text("\(url.lastPathComponent)")
                    
                    Spacer()
                    
                    if !self.scmSaveMode {
                      ExportImageView(url: url, presentURL: self.$presentURL, urlList: self.$urlList)
                    }
                  }
              })
                .isDetailLink(false)
            }
          }
        }.onDelete(perform: deleteRow)
      }
      
      GeometryReader{ geometry in
        HStack {
          TextField("Input filename", text: self.$fileName)
            .frame(height: 50)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
          )
          
          
          Button(action: {
            
            //확장자를 체크하여 저장할려는 확장자와 같다면 패스 아니면 확장자 추가
            let name = self.fileName.components(separatedBy: ".")
            if name[name.count - 1].lowercased() != self.extention.lowercased() {
              self.fileName = name[0]
              for index in 1..<name.count {
                self.fileName.append(".\(name[index])")
              }
              self.fileName.append(".\(self.extention)")
            }
            
            //지금 url에 파일이름 추가
            self.selectSaveURL = self.presentURL.appendingPathComponent(self.fileName, isDirectory: false)
            
            //저장할려는 곳에 같은 이름의 파일이 존재하는지 확인
            if FileManager().fileExists(atPath: self.selectSaveURL.path) {
              self.showAlertFileExist = true
            } else {
              self.seletionPicker()
              //취득화면에서만 저장시 자동으로 창이 닫히게함
              if self.scmSaveMode {
                self.showSelf = false
              } else {
                self.urlList = getChildFromDirectory(url: self.presentURL) //리스트 갱신을 위해 넣어둠
              }
            }
          }) {
            Text("Save")
              .frame(width: geometry.size.width/4, height: 50, alignment: .center)
              .background(Color.orange)
              .cornerRadius(10)
          }
          
        }
      }
      .frame(height: 50)
      .padding(.all, 5)
    }
    .padding(.bottom, keyboard.currentHeight)
    .animation(.easeOut(duration: 0.16))
    .navigationBarTitle("My document folder", displayMode: .inline)
    .navigationBarItems(trailing: rightBarIcons)
    .actionSheet(isPresented: self.$showAlertFileExist) {
      //덮어 씌우기, 복사본 생성, 작업 취소
      ActionSheet(title: Text("Replace Existing Item?"), message: Text("The file already exists in this loation. Do you want to replace it with the one you're copying?"), buttons: [
        ActionSheet.Button.default(Text("Replace"), action: {
          self.seletionPicker()
          //취득화면에서만 저장시 자동으로 창이 닫히게함
          if self.scmSaveMode {
            self.showSelf = false
          } else {
            self.urlList = getChildFromDirectory(url: self.presentURL) //리스트 갱신을 위해 넣어둠
          }
        }),
        ActionSheet.Button.default(Text("Keep Both"), action: {
          self.selectSaveURL = self.GetCopyName(url: self.presentURL, lastPathComponent: self.fileName)
          self.seletionPicker()
          //취득화면에서만 저장시 자동으로 창이 닫히게함
          if self.scmSaveMode {
            self.showSelf = false
          } else {
            self.urlList = getChildFromDirectory(url: self.presentURL) //리스트 갱신을 위해 넣어둠
          }
        }),
        ActionSheet.Button.cancel()
      ])}
  }
  
  //UI관련 쓰는 방법을 알아야 할듯 ㅠㅠ 찾은거에서 다이아로그 띄우는건 제일 깔끔함
  func inputDirectoryNameDialog(){
    let alertController = UIAlertController(title: "Create Directory", message: "Write directory name here", preferredStyle: .alert)
    
    alertController.addTextField { (textField : UITextField!) -> Void in
      textField.placeholder = "Directory name"
    }
    
    let saveAction = UIAlertAction(title: "Ok", style: .default, handler: { alert -> Void in
      
      let secondTextField = alertController.textFields![0] as UITextField
      var directory = getDocumentDirectory()
      directory.appendPathComponent("\(secondTextField.text ?? "")")
      do {
        try FileManager().createDirectory(at: directory, withIntermediateDirectories: false, attributes: .none)
        self.urlList = getChildFromDirectory(url: self.presentURL)
      } catch {
        self.showAlertFolderError = true
        self.messageFolderError = error.localizedDescription
      }
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil )
    
    alertController.addAction(cancelAction)
    alertController.addAction(saveAction)
    
    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
  }
  
  func createFolder() {
    var directory = getDocumentDirectory()
    directory.appendPathComponent("\(self.createFolderName)")
    do {
      try FileManager().createDirectory(at: directory, withIntermediateDirectories: false, attributes: .none)
      self.urlList = getChildFromDirectory(url: self.presentURL)
    } catch {
      self.showAlertFolderError = true
      self.messageFolderError = error.localizedDescription
    }
  }
  func deleteRow(at offsets: IndexSet) {
    do {
      if (offsets.min() != nil) {
        try FileManager().removeItem(at: getChildFromDirectory(url: self.presentURL)[offsets.min()!])
        
        self.urlList = getChildFromDirectory(url: self.presentURL)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  //복사본을 생성할때 이름 지어주기
  func GetCopyName(url: URL, lastPathComponent: String) -> URL {
    var index = 1
    var pathCheck = true
    var tempURL: URL = url
    let components = lastPathComponent.components(separatedBy: ".")
    
    var name: String = ""
    for index in 0..<components.count-1 {
      if index != 0 { name.append(".") }
      name.append(components[index])
    }
    
    while pathCheck {
      tempURL = url.appendingPathComponent("\(name)(\(index)).\(self.extention)")
      
      if !FileManager().fileExists(atPath: tempURL.path) {
        pathCheck = false
      }
      index += 1
    }
    
    return tempURL
  }
}



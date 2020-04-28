//
//  SaveDirectoryView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI
import Combine

struct SaveDirectoryView_Previews: PreviewProvider {
  static var previews: some View {
    SaveDirectoryView(selectSaveURL: .constant(getDocumentDirectory()), presentURL: .constant(getDocumentDirectory()), showSelf: .constant(true), fileName: .constant("temp.SCM"), seletionPicker: {})
  }
}

struct SaveDirectoryView: View {
  @EnvironmentObject var keyboard: KeyboardResponder
  @Binding var selectSaveURL: URL //실제 저장할 파일 경로
  @Binding var presentURL: URL //리스트에 보여지고 있는 경로
  @Binding var showSelf: Bool //네비게이션 뷰를 한번에 닫기 위해
  @Binding var fileName: String //유저가 입력하는 파일 이름
  @State var showAlert: Bool = false //저장 경로 선택 시 파일이 존재할때
  private var seletionPicker: () -> Void //선택한 파일경로로 외부에서 처리하기 위해 호출하는 함수
  
  init(selectSaveURL: Binding<URL>, presentURL: Binding<URL>, showSelf: Binding<Bool>, fileName: Binding<String>, seletionPicker: @escaping () -> Void) {
    self.seletionPicker = seletionPicker
    self._selectSaveURL = selectSaveURL
    self._presentURL = presentURL
    self._showSelf = showSelf
    self._fileName = fileName
  }
  
  var body: some View {
    VStack {
      //현재 디렉토리의 파일리스트
      List {
        //파일이라면
        ForEach(getChildFromDirectory(url: self.presentURL), id: \.self){ url in
          Group {
            if url.filestatus == URL.Filestatus.isFile {
              HStack {
                Image(systemName: "doc.text.fill")
                  .imageScale(.large)
                  .foregroundColor(.yellow)
                Text("\(url.lastPathComponent)")
                  .onTapGesture {
                    self.fileName = url.lastPathComponent
                    print(self.fileName)
                }
              }
            } else {
              //파일이 아니면 폴더라고 처리하고 링크로 만듬
              NavigationLink(
                destination:
                SaveDirectoryView (selectSaveURL: self.$selectSaveURL,
                                   presentURL: .constant(url),
                                   showSelf: self.$showSelf,
                                   fileName: self.$fileName, seletionPicker: self.seletionPicker)
                  .navigationBarTitle("\(url.lastPathComponent)"),
                label: {
                  HStack {
                    Image(systemName: "folder.fill")
                      .imageScale(.large)
                      .foregroundColor(.yellow)
                    
                    Text("\(url.lastPathComponent)")
                  }
              }
              )
                .isDetailLink(false)
            }
          }
        }
      }
      HStack {
        TextField("Input filename", text: $fileName)
        Button(action: {
          self.selectSaveURL = self.presentURL.appendingPathComponent(self.fileName, isDirectory: false)
          
          if FileManager().fileExists(atPath: self.selectSaveURL.path) {
            self.showAlert = true
          } else {
            self.seletionPicker()
            self.showSelf = false
          }
        }) {
          Text("Save")
        }
      }.padding()
    }
    .padding(.bottom, keyboard.currentHeight)
    .edgesIgnoringSafeArea(.bottom)
    .animation(.easeOut(duration: 0.16))
    .navigationBarTitle("My document folder", displayMode: .inline)
    .actionSheet(isPresented: self.$showAlert) {
      //덮어 씌우기, 복사본 생성, 작업 취소
      ActionSheet(title: Text("Replace Existing Item?"), message: Text("The file already exists in this loation. Do you want to replace it with the one you're copying?"), buttons: [
        ActionSheet.Button.default(Text("Replace"), action: {
          self.seletionPicker()
          self.showSelf = false
        }),
        ActionSheet.Button.default(Text("Keep Both"), action: {
          self.selectSaveURL = self.GetCopyName(url: self.presentURL, lastPathComponent: self.fileName)
          self.seletionPicker()
          self.showSelf = false
        }),
        ActionSheet.Button.cancel()
      ])
      
    }
  }
  //복사본을 생성할때 이름 지어주기
  func GetCopyName(url: URL, lastPathComponent: String) -> URL {
    var index = 0
    var pathCheck = true
    var tempURL: URL = url
    
    while pathCheck {
      if index == 0 {
        tempURL = url.appendingPathComponent("copy-\(lastPathComponent)")
      } else {
        tempURL = url.appendingPathComponent("copy(\(index))-\(lastPathComponent)")
      }
      
      if !FileManager().fileExists(atPath: tempURL.path) {
        pathCheck = false
      }
      index += 1
    }
    
    return tempURL
  }
}

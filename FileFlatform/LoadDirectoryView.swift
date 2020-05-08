//
//  LoadDirectoryView.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/16.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct LoadDirectoryView_Previews: PreviewProvider {
  static var previews: some View {
    LoadDirectoryView(selectLoadURL: .constant(getDocumentDirectory()), presentURL: .constant(getDocumentDirectory()), showSelf: .constant(false), seletionPicker: {})
  }
}

struct ExportImageView: View {
  @State var showExportFile = false
  var url: URL
  
  var body: some View {
    Image(systemName: "tray.and.arrow.up")
      .onTapGesture {
        self.showExportFile = true}
      .sheet(
        isPresented: $showExportFile,
        onDismiss: { print("Dismiss") },
        content: { ActivityViewController(activityItems: [self.url]) })
  }
}

struct LoadDirectoryView: View {
  @Binding var presentURL: URL
  @Binding var showSelf: Bool
  @Binding var selectLoadURL: URL
  @State var showAlert = false
  @State var showImportfile = false
  @State private var childURLs: [URL]
  private var seletionPicker: () -> Void //선택한 파일경로로 외부에서 처리하기 위해 호출하는 함수
  
  init(selectLoadURL: Binding<URL>, presentURL: Binding<URL>, showSelf: Binding<Bool>, seletionPicker: @escaping () -> Void) {
    self.seletionPicker = seletionPicker
    self._selectLoadURL = selectLoadURL
    self._presentURL = presentURL
    self._showSelf = showSelf
    self._childURLs = State.init(wrappedValue: getChildFromDirectory(url: presentURL.wrappedValue))
  }
  
  enum CopyMode {
    case replace
    case keepBoth
    case copy
  }
  
  var importFileIcon : some View {
    Button(action: {
      //문서 선택 컨트롤러를 띄움
      self.showImportfile = true
    }, label: {
      Image(systemName: "plus")
        .frame(width: 30, height: 30, alignment: .center)}
    )
      .sheet(isPresented: self.$showImportfile){ () ->
        DocumentPickerViewController in
        DocumentPickerViewController.init(
          //문서를 선택했을 때 함수
          documentPicker: {
            //중복 파일이 있는지 확인
            var nameCheck = false
            for url in pickerURLs {
              let copyURL = self.presentURL.appendingPathComponent(url.lastPathComponent)
              if FileManager().fileExists(atPath: copyURL.path) {
                nameCheck = true
                break
              }
            }
            
            //중복 파일이 없다면 그대로 옮김, 아니면 확인창을 띄움
            if nameCheck {
              self.showAlert = true
            } else {
              self.CopyToFiles(currentURL: self.presentURL, mode: .copy)
            }})}
      .actionSheet(isPresented: self.$showAlert) {
        //덮어 씌우기, 복사본 생성, 작업 취소
        ActionSheet(title: Text("Replace Existing Item?"), message: Text("The file already exists in this loation. Do you want to replace it with the one you're copying?"), buttons: [
          ActionSheet.Button.default(Text("Replace"), action: {
            self.CopyToFiles(currentURL: self.presentURL, mode: .replace)
          }),
          ActionSheet.Button.default(Text("Keep Both"), action: {
            self.CopyToFiles(currentURL: self.presentURL, mode: .keepBoth)
          }),
          ActionSheet.Button.cancel()
        ])}
  }
  
  var body: some View {
    VStack {
      //현재 디렉토리의 파일리스트
      List {
        //파일이라면
        ForEach(self.childURLs, id: \.self){ url in
          Group {
            if url.filestatus == URL.Filestatus.isFile {
              HStack {
                Image(systemName: "doc.text.fill")
                  .foregroundColor(.yellow)
                
                Button(action: {
                  self.selectLoadURL = url
                  self.seletionPicker()
                  self.showSelf = false
                }, label: {Text("\(url.lastPathComponent)")} )
                
                Spacer()
                
                ExportImageView(url: url)
              }
            } else {
              //파일이 아니면 폴더라고 처리하고 링크로 만듬
              NavigationLink(
                destination:
                LoadDirectoryView(selectLoadURL: self.$selectLoadURL, presentURL: .constant(url), showSelf: self.$showSelf, seletionPicker: self.seletionPicker)
                  .navigationBarTitle("\(url.lastPathComponent)"),
                label: {
                  HStack {
                    Image(systemName: "folder.fill")
                      .foregroundColor(.yellow)
                    
                    Text("\(url.lastPathComponent)")
                    
                    Spacer()
                    
                    ExportImageView(url: url)
                  }}
              ).isDetailLink(false)
            }
          }
        }.onDelete(perform: deleteRow)
      }
    }
    .navigationBarItems(trailing: importFileIcon)
    .navigationBarTitle("My document folder", displayMode: .inline)
  }
  
  func deleteRow(at offsets: IndexSet) {
    do {
      if (offsets.min() != nil) {
        try FileManager().removeItem(at: getChildFromDirectory(url: self.presentURL)[offsets.min()!])
        self.childURLs = getChildFromDirectory(url: self.presentURL) //리스트 갱신을 위해 넣어둠
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  //옮길지, 덮어씌울지, 복사본을 만들지
  func CopyToFiles(currentURL: URL, mode: CopyMode) {
    do {
      for url in pickerURLs {
        var fullURL: URL {
          if mode == .keepBoth {
            return self.GetCopyName(url: currentURL, lastPathComponent: url.lastPathComponent)
          } else {
            return currentURL.appendingPathComponent(url.lastPathComponent)
          }
        }
        
        if mode == .replace && FileManager().fileExists(atPath: fullURL.path){
          try FileManager().removeItem(at: fullURL)
          print("remove Item")
        }
        
        try FileManager().copyItem(at: url, to: fullURL)
      }
    } catch {
      print(error.localizedDescription)
    }
    self.childURLs = getChildFromDirectory(url: self.presentURL) //리스트 갱신을 위해 넣어둠
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


//
//  RectangleProgressBar.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/05.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI
import Combine

struct RectangleProgressBar: View {
  @State private var increment = true
  @State private var currentIndex = 0
  private var maxIndex = 10
  @State private var publisher = PassthroughSubject<AnimationStatus, Never>()
  @State var timer: Timer?
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ForEach(0..<maxIndex, id: \.self) { id in
        KnightRiderRect(index:id, publisher:self.publisher)
      }
      
    }
    .background(Color.black)
    .onAppear {
      self.timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
        if self.increment {
          if self.currentIndex > self.maxIndex {
            self.increment = false
            self.currentIndex = self.maxIndex
            self.publisher.send(.stopAll)
          }
          else {
            self.publisher.send(.start(index: self.currentIndex))
            self.currentIndex += 1
          }
        }
        else {
          if self.currentIndex < -1 {
            self.increment = true
            self.currentIndex = 0
            self.publisher.send(.stopAll)
          }
          else {
            self.publisher.send(.start(index: self.currentIndex))
            self.currentIndex -= 1
          }
        }
      }
    }
    .onDisappear() {
      if self.timer?.isValid ?? false {
        self.timer?.invalidate()
      }
    }
  }
}

struct RectangleProgressBar_Previews: PreviewProvider {
  static var previews: some View {
    RectangleProgressBar()
  }
}

struct KnightRiderRect: View {
  var index:Int
  var publisher:PassthroughSubject<AnimationStatus, Never>
  
  @State private var animate = false
  
  var body: some View {
    Rectangle()
      .foregroundColor(Color.blue)
      .opacity(animate ? 1 : 0.2)
      .animation(Animation.linear(duration: 0.3))
      .onReceive(publisher) { value in
        switch value {
        case .start(let index):
          if index == self.index {
            self.animate = true
          }
          else {
            self.animate = false
          }
        case .stop(let index):
          if index == self.index {
            self.animate = false
          }
        case .stopAll:
          self.animate = false
        }
        
    }
  }
}

enum AnimationStatus {
  case start(index:Int)
  case stop(index:Int)
  case stopAll
}

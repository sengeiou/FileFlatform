//
//  CircleProgressBar.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/05/05.
//  Copyright © 2020 mcsco. All rights reserved.
//

import SwiftUI

struct CircleProgressBar: View {
  @State var degress = 0.0
  @State var timer: Timer?
  @State var lineStroke: CGFloat
  
  var body: some View {
    Circle()
      .trim(from: 0.0, to: 0.6)
      .stroke(Color.blue, lineWidth: self.lineStroke)
      .rotationEffect(Angle(degrees: degress))
      .onAppear(perform: {self.start()})
      .onDisappear(){self.stop()}
      .padding()
  }
  
  func start() {
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
      withAnimation {
        self.degress += 10.0
      }
      if self.degress == 360.0 {
        self.degress = 0.0
      }
    }
  }
  
  func stop() {
    if self.timer?.isValid ?? false {
      self.timer?.invalidate()
    }
  }
}


struct CircleProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircleProgressBar(lineStroke: 4)
    }
}



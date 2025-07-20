// Copyright © 2025 Snap, Inc. All rights reserved.

import SwiftUI
import MathEditor

struct ContentView: View {
    var body: some View {
      MathEditorView()
        .padding()
    }
}

#Preview {
    ContentView()
}

#if os(iOS)
struct MathEditorView : UIViewRepresentable {
  typealias UIViewType = MTEditableMathLabel
  
  func makeUIView(context: Context) -> MTEditableMathLabel {
    let mathLabel = MTEditableMathLabel()
    mathLabel.keyboard = MTMathKeyboardRootView.sharedInstance()
    mathLabel.backgroundColor = .clear
    return mathLabel
  }
  
  func updateUIView(_ uiView: MTEditableMathLabel, context: Context) {
    
  }
}
#endif

#if os(macOS)
struct MathEditorView : NSViewRepresentable {
  typealias NSViewType = MTEditableMathLabel
  
  func makeNSView(context: Context) -> MTEditableMathLabel {
    let mathLabel = MTEditableMathLabel()
    mathLabel.keyboard = MTMathKeyboardRootView.sharedInstance()
    mathLabel.backgroundColor = .clear
    return mathLabel
  }
  
  func updateNSView(_ uiView: MTEditableMathLabel, context: Context) {
    
  }
}
#endif

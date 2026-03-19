// Copyright © 2025 Snap, Inc. All rights reserved.

import SwiftUI
import MathEditor
import MathKeyboard

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
    mathLabel.backgroundColor = .clear
    mathLabel.keyboard = MTMathKeyboardRootView.sharedInstance();
    return mathLabel
  }
  
  func updateUIView(_ uiView: MTEditableMathLabel, context: Context) {
    
  }
}
#endif

#if os(macOS)
struct MathEditorView: View {
  var body: some View {
    Text("MathEditor is not wired up for macOS in this example yet.")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
#endif

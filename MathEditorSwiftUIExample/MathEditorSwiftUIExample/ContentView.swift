// Copyright © 2025 Snap, Inc. All rights reserved.

import MathEditor
import SwiftUI

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
  import MathKeyboard

  struct MathEditorView: UIViewRepresentable {
    typealias UIViewType = MTEditableMathLabel

    func makeUIView(context: Context) -> MTEditableMathLabel {
      let mathLabel = MTEditableMathLabel()
      mathLabel.backgroundColor = .clear
      mathLabel.keyboard = MTMathKeyboardRootView.sharedInstance()
      return mathLabel
    }

    func updateUIView(_ uiView: MTEditableMathLabel, context: Context) {

    }
  }
#endif  // os(iOS)

#if os(macOS)

  struct MathEditorView: NSViewRepresentable {
    typealias UIViewType = MTEditableMathLabel

    func makeNSView(context: Context) -> MTEditableMathLabel {
      let mathLabel = MTEditableMathLabel()
      mathLabel.backgroundColor = .clear
      //    mathLabel.keyboard = MTMathKeyboardRootView.sharedInstance();
      return mathLabel
    }

    func updateNSView(_ uiView: MTEditableMathLabel, context: Context) {

    }
  }

#endif

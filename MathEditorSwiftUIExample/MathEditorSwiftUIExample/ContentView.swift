// Copyright © 2025 Snap, Inc. All rights reserved.

import MathEditor
import SwiftUI

struct ContentView: View {
  var body: some View {
    MathEditorView()
      .frame(maxHeight: 100)
      .padding()
  }
}

#Preview {
  ContentView()
}

#if os(iOS)
  import MathKeyboard
  import MathKeyboardSwiftUI

  struct MathEditorView: UIViewRepresentable {
    typealias UIViewType = MTEditableMathLabel

    func makeUIView(context: Context) -> MTEditableMathLabel {
      let mathLabel = MTEditableMathLabel()
      mathLabel.backgroundColor = .clear
      mathLabel.keyboard = MTMathKeyboardSwiftUIRootView.sharedInstance()
      return mathLabel
    }

    func updateUIView(_ uiView: MTEditableMathLabel, context: Context) {

    }
  }
#endif  // os(iOS)

#if os(macOS)

  struct MathEditorView: NSViewRepresentable {
    typealias UIViewType = NSView

    func makeNSView(context: Context) -> NSView {
      let mathLabel = MTEditableMathLabel()
      mathLabel.backgroundColor = .clear
      mathLabel.caretColor = NSColor.labelColor
      mathLabel.textColor = NSColor.labelColor
      //    mathLabel.keyboard = MTMathKeyboardRootView.sharedInstance();

      let wrapper = NSView()
      wrapper.addSubview(mathLabel)
      mathLabel.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        mathLabel.topAnchor.constraint(equalTo: wrapper.topAnchor),
        mathLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
        mathLabel.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
        mathLabel.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -44),
      ])
      wrapper.backgroundColor = .clear
      return wrapper
    }

    func updateNSView(_ nsView: NSView, context: Context) {

    }
  }

#endif

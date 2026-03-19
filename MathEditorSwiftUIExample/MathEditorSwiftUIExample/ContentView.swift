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
private enum KeyboardTab: CaseIterable {
  case numbers
  case operations
  case functions
  case letters
}

private final class KeyboardState: ObservableObject {
  weak var textView: (UIView & UIKeyInput)?

  @Published var tab: KeyboardTab = .numbers
  @Published var isLowerCase = true
  @Published var equalsAllowed = true
  @Published var variablesAllowed = true
  @Published var numbersAllowed = true
  @Published var operatorsAllowed = true
  @Published var exponentHighlighted = false
  @Published var squareRootHighlighted = false
  @Published var radicalHighlighted = false

  func insert(_ text: String) { textView?.insertText(text) }
  func backspace() { textView?.deleteBackward() }
  func dismiss() { textView?.resignFirstResponder() }
}

private struct KeyboardButton: View {
  let title: String
  var enabled: Bool = true
  var selected: Bool = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .foregroundStyle(enabled ? Color.primary : Color.secondary)
        .background(selected ? Color.blue.opacity(0.2) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    .buttonStyle(.plain)
    .disabled(!enabled)
  }
}

private struct MathKeyboardSwiftUIView: View {
  @ObservedObject var state: KeyboardState

  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 6) {
        tabButton(.numbers, title: "123")
        tabButton(.operations, title: "+−×")
        tabButton(.functions, title: "ƒx")
        tabButton(.letters, title: "ABC")
      }

      tabContent

      HStack(spacing: 6) {
        KeyboardButton(title: "⌫") { state.backspace() }
        KeyboardButton(title: "Return") { state.insert("\n") }
        KeyboardButton(title: "Hide") { state.dismiss() }
      }
    }
    .padding(8)
    .background(Color(UIColor.systemGray5))
  }

  private func tabButton(_ tab: KeyboardTab, title: String) -> some View {
    KeyboardButton(title: title, selected: state.tab == tab) {
      state.tab = tab
    }
  }

  @ViewBuilder
  private var tabContent: some View {
    switch state.tab {
    case .numbers:
      rows([["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["0", ".", "="]], enabled: state.numbersAllowed) { key in
        state.insert(key)
      }
    case .operations:
      rows([["+", "-", "*", "/"], ["<", ">", "≤", "≥"], ["(", ")", "||", "_"]], enabled: state.operatorsAllowed) { key in
        state.insert(key)
      }
    case .functions:
      rows([["/", "^", "√", "∛"], ["sin", "cos", "tan", "log"], ["ln", "π", "e"]], enabled: true) { key in
        switch key {
        case "/": state.insert(MTSymbolFractionSlash)
        case "√": state.insert(MTSymbolSquareRoot)
        case "∛": state.insert(MTSymbolCubeRoot)
        case "log":
          state.insert("log")
          state.insert("_")
        case "π": state.insert("\\pi")
        default: state.insert(key)
        }
      }
    case .letters:
      VStack(spacing: 6) {
        rows([["a", "b", "c", "x", "y", "z"], ["m", "n", "p", "q", "r", "s"]].map { row in
          row.map { state.isLowerCase ? $0 : $0.uppercased() }
        }, enabled: state.variablesAllowed) { key in
          state.insert(key)
        }
        HStack(spacing: 6) {
          KeyboardButton(title: state.isLowerCase ? "⇧" : "⇩") {
            state.isLowerCase.toggle()
          }
          ForEach(state.isLowerCase ? ["α", "Δ", "σ", "μ", "λ"] : ["ρ", "ω", "Φ", "ν", "β"], id: \.self) { letter in
            KeyboardButton(title: letter, enabled: state.variablesAllowed) {
              state.insert(letter)
            }
          }
        }
      }
    }
  }

  private func rows(_ rows: [[String]], enabled: Bool, action: @escaping (String) -> Void) -> some View {
    VStack(spacing: 6) {
      ForEach(rows.indices, id: \.self) { rowIndex in
        HStack(spacing: 6) {
          ForEach(rows[rowIndex], id: \.self) { key in
            KeyboardButton(
              title: key,
              enabled: enabled && !(key == "=" && !state.equalsAllowed),
              selected: (key == "^" && state.exponentHighlighted) || (key == "√" && state.squareRootHighlighted) || (key == "∛" && state.radicalHighlighted)
            ) {
              action(key)
            }
          }
        }
      }
    }
  }
}

final class SwiftUIMathKeyboard: UIView, MTMathKeyboard {
  private let state = KeyboardState()
  private lazy var host = UIHostingController(rootView: MathKeyboardSwiftUIView(state: state))

  var equalsAllowed: Bool = true { didSet { state.equalsAllowed = equalsAllowed } }
  var fractionsAllowed: Bool = true
  var variablesAllowed: Bool = true { didSet { state.variablesAllowed = variablesAllowed } }
  var numbersAllowed: Bool = true { didSet { state.numbersAllowed = numbersAllowed } }
  var operatorsAllowed: Bool = true { didSet { state.operatorsAllowed = operatorsAllowed } }
  var exponentHighlighted: Bool = false { didSet { state.exponentHighlighted = exponentHighlighted } }
  var squareRootHighlighted: Bool = false { didSet { state.squareRootHighlighted = squareRootHighlighted } }
  var radicalHighlighted: Bool = false { didSet { state.radicalHighlighted = radicalHighlighted } }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    let hostedView = host.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hostedView)
    NSLayoutConstraint.activate([
      hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
      hostedView.topAnchor.constraint(equalTo: topAnchor),
      hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  func startedEditing(_ label: UIView & UIKeyInput) {
    state.textView = label
  }

  func finishedEditing(_ label: UIView & UIKeyInput) {
    state.textView = nil
  }
}

struct MathEditorView : UIViewRepresentable {
  typealias UIViewType = MTEditableMathLabel

  func makeUIView(context: Context) -> MTEditableMathLabel {
    let mathLabel = MTEditableMathLabel()
    mathLabel.keyboard = SwiftUIMathKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250))
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

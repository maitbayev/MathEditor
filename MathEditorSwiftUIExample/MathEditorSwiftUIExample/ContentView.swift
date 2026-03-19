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
private enum KeyboardTab: Int, CaseIterable {
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

private struct KeyboardKey: View {
  let title: String
  var width: CGFloat
  var height: CGFloat = 45
  var enabled: Bool = true
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        Rectangle()
          .fill(enabled ? Color.white : Color(white: 0.86))
          .overlay(Rectangle().stroke(Color(white: 0.75), lineWidth: 0.5))
        Text(title)
          .font(.system(size: 22, weight: .light))
          .foregroundStyle(enabled ? Color.black : Color.gray)
      }
      .frame(width: width, height: height)
    }
    .buttonStyle(.plain)
    .disabled(!enabled)
  }
}

private struct IconTabButton: View {
  let normalImage: String
  let selectedImage: String
  let selected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(uiImage: keyboardImage(named: selected ? selectedImage : normalImage))
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 45)
        .clipped()
    }
    .buttonStyle(.plain)
  }

  private func keyboardImage(named name: String) -> UIImage {
    UIImage(named: name, in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(), compatibleWith: nil) ?? UIImage()
  }
}

private struct MathKeyboardSwiftUIView: View {
  @ObservedObject var state: KeyboardState

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        IconTabButton(normalImage: "Numbers Symbol wbg", selectedImage: "Number Symbol", selected: state.tab == .numbers) { state.tab = .numbers }
        IconTabButton(normalImage: "Operations Symbol wbg", selectedImage: "Operations Symbol", selected: state.tab == .operations) { state.tab = .operations }
        IconTabButton(normalImage: "Functions Symbol wbg", selectedImage: "Functions Symbol", selected: state.tab == .functions) { state.tab = .functions }
        IconTabButton(normalImage: "Letter Symbol wbg", selectedImage: "Letter Symbol", selected: state.tab == .letters) { state.tab = .letters }
      }
      .frame(height: 45)

      ZStack {
        Rectangle().fill(Color.white)
        tabContent
      }
      .frame(height: 180)
    }
    .frame(width: 320, height: 225)
    .background(Color.white)
  }

  @ViewBuilder
  private var tabContent: some View {
    switch state.tab {
    case .numbers:
      threeByFourGrid(
        leftColumns: [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["0", ".", "="]],
        rightColumn: ["⌫", "Enter", "⌄"],
        leftEnabled: state.numbersAllowed
      ) { key in
        if key == "=" && !state.equalsAllowed { return }
        state.insert(key)
      } rightAction: { key in
        actionForSideKey(key)
      }

    case .operations:
      threeByFourGrid(
        leftColumns: [["<", ">", "≤"], ["≥", "≠", "≈"], ["+", "−", "×"], ["÷", "(", ")"]],
        rightColumn: ["⌫", "Enter", "⌄"],
        leftEnabled: state.operatorsAllowed
      ) { key in
        switch key {
        case "−": state.insert("-")
        case "×": state.insert("*")
        case "÷": state.insert("/")
        default: state.insert(key)
        }
      } rightAction: { key in
        actionForSideKey(key)
      }

    case .functions:
      threeByFourGrid(
        leftColumns: [["√", "∛", "^"], ["/", "_", "log"], ["sin", "cos", "tan"], ["ln", "π", "e"]],
        rightColumn: ["⌫", "Enter", "⌄"],
        leftEnabled: true
      ) { key in
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
      } rightAction: { key in
        actionForSideKey(key)
      }

    case .letters:
      threeByFourGrid(
        leftColumns: [[display("a"), display("b"), display("c")], [display("x"), display("y"), display("z")], [display("m"), display("n"), display("p")], [display("⇧"), greek1, greek2]],
        rightColumn: [greek3, greek4, greek5],
        leftEnabled: state.variablesAllowed
      ) { key in
        if key == display("⇧") {
          state.isLowerCase.toggle()
        } else {
          state.insert(key)
        }
      } rightAction: { key in
        state.insert(key)
      }
    }
  }

  private var greek1: String { state.isLowerCase ? "α" : "ρ" }
  private var greek2: String { state.isLowerCase ? "Δ" : "ω" }
  private var greek3: String { state.isLowerCase ? "σ" : "Φ" }
  private var greek4: String { state.isLowerCase ? "μ" : "ν" }
  private var greek5: String { state.isLowerCase ? "λ" : "β" }

  private func display(_ letter: String) -> String {
    state.isLowerCase ? letter.lowercased() : letter.uppercased()
  }

  private func actionForSideKey(_ key: String) {
    switch key {
    case "⌫": state.backspace()
    case "Enter": state.insert("\n")
    default: state.dismiss()
    }
  }

  private func threeByFourGrid(
    leftColumns: [[String]],
    rightColumn: [String],
    leftEnabled: Bool,
    leftAction: @escaping (String) -> Void,
    rightAction: @escaping (String) -> Void
  ) -> some View {
    HStack(spacing: 0) {
      HStack(spacing: 0) {
        ForEach(0..<4, id: \.self) { column in
          VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
              let key = leftColumns[column][row]
              KeyboardKey(
                title: key,
                width: column == 0 ? 49 : 50,
                enabled: leftEnabled && !(key == "=" && !state.equalsAllowed)
              ) {
                leftAction(key)
              }
            }
          }
        }
      }

      VStack(spacing: 0) {
        KeyboardKey(title: rightColumn[0], width: 72) { rightAction(rightColumn[0]) }
        KeyboardKey(title: rightColumn[1], width: 72, height: 90) { rightAction(rightColumn[1]) }
        KeyboardKey(title: rightColumn[2], width: 72) { rightAction(rightColumn[2]) }
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
    mathLabel.keyboard = SwiftUIMathKeyboard(frame: CGRect(x: 0, y: 0, width: 320, height: 225))
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

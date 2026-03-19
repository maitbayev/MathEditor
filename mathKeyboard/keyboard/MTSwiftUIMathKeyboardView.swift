import SwiftUI
import UIKit
import iosMath

private enum MTKeyboardTab: Int {
  case numbers = 0
  case operations = 1
  case functions = 2
  case letters = 3
}

private final class MTKeyboardState: ObservableObject {
  weak var textView: (UIView & UIKeyInput)?

  @Published var tab: MTKeyboardTab = .numbers
  @Published var isLowerCase = true

  @Published var equalsAllowed = true
  @Published var fractionsAllowed = true
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

private struct MTKeyboardTabButton: View {
  let normalImage: String
  let selectedImage: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(uiImage: image(named: isSelected ? selectedImage : normalImage))
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 45)
        .clipped()
    }
    .buttonStyle(.plain)
  }

  private func image(named name: String) -> UIImage {
    UIImage(named: name, in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(), compatibleWith: nil) ?? UIImage()
  }
}

private struct MTKeyboardKey: View {
  let title: String
  let width: CGFloat
  let height: CGFloat
  let enabled: Bool
  let highlighted: Bool
  let action: () -> Void

  init(title: String, width: CGFloat, height: CGFloat = 45, enabled: Bool = true, highlighted: Bool = false, action: @escaping () -> Void) {
    self.title = title
    self.width = width
    self.height = height
    self.enabled = enabled
    self.highlighted = highlighted
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      ZStack {
        Rectangle()
          .fill(backgroundColor)
          .overlay(Rectangle().stroke(Color(white: 0.75), lineWidth: 0.5))
        Text(title)
          .font(.system(size: 20, weight: .light))
          .foregroundStyle(enabled ? Color.black : Color.gray)
      }
      .frame(width: width, height: height)
    }
    .buttonStyle(.plain)
    .disabled(!enabled)
  }

  private var backgroundColor: Color {
    if !enabled { return Color(white: 0.86) }
    if highlighted { return Color(red: 0.74, green: 0.91, blue: 0.99) }
    return Color.white
  }
}

private struct MTSwiftUIKeyboardBody: View {
  @ObservedObject var state: MTKeyboardState

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        MTKeyboardTabButton(normalImage: "Numbers Symbol wbg", selectedImage: "Number Symbol", isSelected: state.tab == .numbers) { state.tab = .numbers }
        MTKeyboardTabButton(normalImage: "Operations Symbol wbg", selectedImage: "Operations Symbol", isSelected: state.tab == .operations) { state.tab = .operations }
        MTKeyboardTabButton(normalImage: "Functions Symbol wbg", selectedImage: "Functions Symbol", isSelected: state.tab == .functions) { state.tab = .functions }
        MTKeyboardTabButton(normalImage: "Letter Symbol wbg", selectedImage: "Letter Symbol", isSelected: state.tab == .letters) { state.tab = .letters }
      }
      .frame(height: 45)

      ZStack {
        Color.white
        content
      }
      .frame(height: 180)
    }
    .frame(width: 320, height: 225)
  }

  @ViewBuilder
  private var content: some View {
    switch state.tab {
    case .numbers:
      grid(
        leftColumns: [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["0", ".", "="]],
        rightColumn: ["⌫", "Enter", "⌄"],
        leftEnabled: state.numbersAllowed
      ) { key in
        state.insert(key)
      }
    case .operations:
      grid(
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
      }
    case .functions:
      grid(
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
      }
    case .letters:
      grid(
        leftColumns: [[letter("a"), letter("b"), letter("c")], [letter("x"), letter("y"), letter("z")], [letter("m"), letter("n"), letter("p")], ["⇧", greek1, greek2]],
        rightColumn: [greek3, greek4, greek5],
        leftEnabled: state.variablesAllowed
      ) { key in
        if key == "⇧" {
          state.isLowerCase.toggle()
        } else {
          state.insert(key)
        }
      }
    }
  }

  private var greek1: String { state.isLowerCase ? "α" : "ρ" }
  private var greek2: String { state.isLowerCase ? "Δ" : "ω" }
  private var greek3: String { state.isLowerCase ? "σ" : "Φ" }
  private var greek4: String { state.isLowerCase ? "μ" : "ν" }
  private var greek5: String { state.isLowerCase ? "λ" : "β" }

  private func letter(_ base: String) -> String {
    state.isLowerCase ? base.lowercased() : base.uppercased()
  }

  private func sideAction(_ key: String) {
    switch key {
    case "⌫": state.backspace()
    case "Enter": state.insert("\n")
    default: state.dismiss()
    }
  }

  private func grid(
    leftColumns: [[String]],
    rightColumn: [String],
    leftEnabled: Bool,
    insertAction: @escaping (String) -> Void
  ) -> some View {
    HStack(spacing: 0) {
      HStack(spacing: 0) {
        ForEach(0..<4, id: \.self) { col in
          VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
              let key = leftColumns[col][row]
              MTKeyboardKey(
                title: key,
                width: col == 0 ? 49 : 50,
                enabled: leftEnabled && !(key == "=" && !state.equalsAllowed),
                highlighted: (key == "^" && state.exponentHighlighted) || (key == "√" && state.squareRootHighlighted) || (key == "∛" && state.radicalHighlighted)
              ) {
                insertAction(key)
              }
            }
          }
        }
      }

      VStack(spacing: 0) {
        MTKeyboardKey(title: rightColumn[0], width: 72) { sideAction(rightColumn[0]) }
        MTKeyboardKey(title: rightColumn[1], width: 72, height: 90) { sideAction(rightColumn[1]) }
        MTKeyboardKey(title: rightColumn[2], width: 72) { sideAction(rightColumn[2]) }
      }
    }
  }
}

@objcMembers
public final class MTSwiftUIMathKeyboardView: UIView {
  private let state = MTKeyboardState()
  private lazy var host = UIHostingController(rootView: MTSwiftUIKeyboardBody(state: state))

  public weak var textView: (UIView & UIKeyInput)? {
    didSet { state.textView = textView }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    backgroundColor = .clear
    let hosted = host.view!
    hosted.backgroundColor = .clear
    hosted.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hosted)
    NSLayoutConstraint.activate([
      hosted.leadingAnchor.constraint(equalTo: leadingAnchor),
      hosted.trailingAnchor.constraint(equalTo: trailingAnchor),
      hosted.topAnchor.constraint(equalTo: topAnchor),
      hosted.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  public func setCurrentTab(_ tab: Int) { state.tab = MTKeyboardTab(rawValue: tab) ?? .numbers }
  public func setEqualsAllowed(_ enabled: Bool) { state.equalsAllowed = enabled }
  public func setFractionsAllowed(_ enabled: Bool) { state.fractionsAllowed = enabled }
  public func setVariablesAllowed(_ enabled: Bool) { state.variablesAllowed = enabled }
  public func setNumbersAllowed(_ enabled: Bool) { state.numbersAllowed = enabled }
  public func setOperatorsAllowed(_ enabled: Bool) { state.operatorsAllowed = enabled }
  public func setExponentHighlighted(_ highlighted: Bool) { state.exponentHighlighted = highlighted }
  public func setSquareRootHighlighted(_ highlighted: Bool) { state.squareRootHighlighted = highlighted }
  public func setRadicalHighlighted(_ highlighted: Bool) { state.radicalHighlighted = highlighted }
}

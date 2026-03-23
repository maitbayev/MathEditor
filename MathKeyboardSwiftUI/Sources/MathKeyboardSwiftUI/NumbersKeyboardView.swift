#if os(iOS)

  import MathEditor
  import MathKeyboard
  import Observation
  import SwiftUI
  import CoreText
  import Foundation
  import UIKit

  protocol KeyboardConfigurable: AnyObject {
    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?)
    func setNumbersState(_ enabled: Bool)
    func setOperatorState(_ enabled: Bool)
    func setVariablesState(_ enabled: Bool)
    func setFractionState(_ enabled: Bool)
    func setEqualsState(_ enabled: Bool)
    func setExponentState(_ highlighted: Bool)
    func setSquareRootState(_ highlighted: Bool)
    func setRadicalState(_ highlighted: Bool)
  }

  extension MTKeyboard: KeyboardConfigurable {
    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?) {
      self.textView = textView
    }
  }

  @Observable
  final class NumbersKeyboardModel {
    var numbersAllowed = true
    var operatorsAllowed = true
    var variablesAllowed = true
    var fractionsAllowed = true
    var equalsAllowed = true
    var exponentHighlighted = false
  }

  private enum KeyboardFontRegistry {
    static let variableFontName: String = {
      guard let bundle = MTMathKeyboardRootView.getMathKeyboardResourcesBundle() else {
        return "HelveticaNeue"
      }
      guard
        let fontURL = bundle.url(forResource: "lmroman10-bolditalic", withExtension: "otf"),
        let provider = CGDataProvider(url: fontURL as CFURL),
        let font = CGFont(provider)
      else {
        return "HelveticaNeue"
      }

      let postScriptName = font.postScriptName as String? ?? "HelveticaNeue"
      var error: Unmanaged<CFError>?
      CTFontManagerRegisterGraphicsFont(font, &error)
      return postScriptName
    }()
  }

  final class NumbersKeyboardHostView: UIView, KeyboardConfigurable, UIInputViewAudioFeedback {
    private let model = NumbersKeyboardModel()
    private weak var editingTarget: (any UIView & UIKeyInput)?
    private lazy var hostingController = UIHostingController(rootView: makeRootView())

    override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }

    required init?(coder: NSCoder) {
      super.init(coder: coder)
      commonInit()
    }

    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?) {
      editingTarget = textView
    }

    func setNumbersState(_ enabled: Bool) {
      updateModel(\.numbersAllowed, to: enabled)
    }

    func setOperatorState(_ enabled: Bool) {
      updateModel(\.operatorsAllowed, to: enabled)
    }

    func setVariablesState(_ enabled: Bool) {
      updateModel(\.variablesAllowed, to: enabled)
    }

    func setFractionState(_ enabled: Bool) {
      updateModel(\.fractionsAllowed, to: enabled)
    }

    func setEqualsState(_ enabled: Bool) {
      updateModel(\.equalsAllowed, to: enabled)
    }

    func setExponentState(_ highlighted: Bool) {
      updateModel(\.exponentHighlighted, to: highlighted)
    }

    func setSquareRootState(_ highlighted: Bool) {}

    func setRadicalState(_ highlighted: Bool) {}

    var enableInputClicksWhenVisible: Bool { true }

    private func commonInit() {
      backgroundColor = .white

      let hostedView = hostingController.view!
      if #available(iOS 16.4, *) {
        hostingController.safeAreaRegions = []
      }
      hostedView.backgroundColor = .clear
      hostedView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(hostedView)

      NSLayoutConstraint.activate([
        hostedView.topAnchor.constraint(equalTo: topAnchor),
        hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
        hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
        hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
    }

    private func makeRootView() -> NumbersKeyboardView {
      NumbersKeyboardView(
        model: model,
        onInsertText: { [weak self] text in self?.insert(text) },
        onBackspace: { [weak self] in self?.backspace() },
        onDismiss: { [weak self] in self?.dismissKeyboard() }
      )
    }

    private func insert(_ text: String) {
      playClickForCustomKeyTap()
      editingTarget?.insertText(text)
    }

    private func backspace() {
      playClickForCustomKeyTap()
      editingTarget?.deleteBackward()
    }

    private func dismissKeyboard() {
      playClickForCustomKeyTap()
      editingTarget?.resignFirstResponder()
    }

    private func playClickForCustomKeyTap() {
      UIDevice.current.playInputClick()
    }

    private func updateModel(
      _ keyPath: ReferenceWritableKeyPath<NumbersKeyboardModel, Bool>,
      to value: Bool
    ) {
      guard model[keyPath: keyPath] != value else { return }

      DispatchQueue.main.async { [weak self] in
        guard let self, self.model[keyPath: keyPath] != value else { return }
        self.model[keyPath: keyPath] = value
      }
    }
  }

  struct NumbersKeyboardView: View {
    let model: NumbersKeyboardModel
    let onInsertText: (String) -> Void
    let onBackspace: () -> Void
    let onDismiss: () -> Void

    var body: some View {
      GeometryReader { proxy in
        let totalWidth = proxy.size.width
        let totalHeight = proxy.size.height
        let utilityWidth = totalWidth * 0.225
        let standardColumnWidth = (totalWidth - utilityWidth) / 5
        let rowHeight = totalHeight / 4

        HStack(spacing: 0) {
          keyboardColumn(items: featureItems, width: standardColumnWidth, rowHeight: rowHeight)
          keyboardColumn(items: numbersLeftItems, width: standardColumnWidth, rowHeight: rowHeight)
          keyboardColumn(items: numbersMiddleItems, width: standardColumnWidth, rowHeight: rowHeight)
          keyboardColumn(items: numbersRightItems, width: standardColumnWidth, rowHeight: rowHeight)
          keyboardColumn(items: operatorItems, width: standardColumnWidth, rowHeight: rowHeight)
          utilityColumn(width: utilityWidth, rowHeight: rowHeight)
        }
        .frame(width: totalWidth, height: totalHeight)
        .background(.white)
      }
    }

    private func keyboardColumn(items: [KeyboardCell], width: CGFloat, rowHeight: CGFloat) -> some View {
      VStack(spacing: 0) {
        ForEach(items) { item in
          keyButton(item)
            .frame(width: width, height: rowHeight)
        }
      }
    }

    private func utilityColumn(width: CGFloat, rowHeight: CGFloat) -> some View {
      VStack(spacing: 0) {
        keyButton(utilityBackspace)
          .frame(width: width, height: rowHeight)
        keyButton(utilityEnter)
          .frame(width: width, height: rowHeight * 2)
        keyButton(utilityDismiss)
          .frame(width: width, height: rowHeight)
      }
    }

    private func keyButton(_ cell: KeyboardCell) -> some View {
      Button(action: cell.action) {
        ZStack {
          Rectangle().fill(cell.backgroundColor)
          cell.label
        }
      }
      .buttonStyle(.plain)
      .disabled(!cell.enabled)
      .opacity(cell.enabled ? 1 : 0.6)
      .overlay(
        Rectangle()
          .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
      )
      .accessibilityLabel(cell.accessibilityLabel)
    }

    private var featureItems: [KeyboardCell] {
      [
        .text(
          label: "x", foreground: .white, background: .blueKey, fontName: KeyboardFontRegistry.variableFontName,
          action: { onInsertText("x") }, enabled: model.variablesAllowed),
        .text(
          label: "y", foreground: .white, background: .blueKey, fontName: KeyboardFontRegistry.variableFontName,
          action: { onInsertText("y") }, enabled: model.variablesAllowed),
        .image(
          imageName: "Fraction", background: .blueKey,
          action: { onInsertText(MTSymbolFractionSlash) }, enabled: model.fractionsAllowed,
          accessibilityLabel: "Fraction"),
        .image(
          imageName: "Exponent", background: model.exponentHighlighted ? .highlightBlue : .blueKey,
          action: { onInsertText("^") }, enabled: true, accessibilityLabel: "Exponent"),
      ]
    }

    private var numbersLeftItems: [KeyboardCell] {
      numberColumn(["7", "4", "1", "0"])
    }

    private var numbersMiddleItems: [KeyboardCell] {
      numberColumn(["8", "5", "2", "."])
    }

    private var numbersRightItems: [KeyboardCell] {
      [
        .number("9", action: { onInsertText("9") }, enabled: model.numbersAllowed),
        .number("6", action: { onInsertText("6") }, enabled: model.numbersAllowed),
        .number("3", action: { onInsertText("3") }, enabled: model.numbersAllowed),
        .text(
          label: "=", foreground: model.equalsAllowed ? .black : Color(white: 0.67), background: .numberKey,
          action: { onInsertText("=") }, enabled: model.equalsAllowed),
      ]
    }

    private var operatorItems: [KeyboardCell] {
      [
        .operator("÷", action: { onInsertText("÷") }, enabled: model.operatorsAllowed),
        .operator("×", action: { onInsertText("×") }, enabled: model.operatorsAllowed),
        .operator("-", action: { onInsertText("-") }, enabled: model.operatorsAllowed),
        .operator("+", action: { onInsertText("+") }, enabled: model.operatorsAllowed),
      ]
    }

    private var utilityBackspace: KeyboardCell {
      .image(
        imageName: "Backspace", background: .utilityKey,
        action: onBackspace, enabled: true, accessibilityLabel: "Backspace")
    }

    private var utilityEnter: KeyboardCell {
      .text(
        label: "Enter", foreground: .white, background: .utilityKey,
        action: { onInsertText("\n") }, enabled: true)
    }

    private var utilityDismiss: KeyboardCell {
      .image(
        imageName: "Keyboard Down", background: .utilityKey,
        action: onDismiss, enabled: true, accessibilityLabel: "Dismiss keyboard")
    }

    private func numberColumn(_ values: [String]) -> [KeyboardCell] {
      values.map { value in
        .number(value, action: { onInsertText(value) }, enabled: model.numbersAllowed)
      }
    }

  }

  private struct KeyboardCell: Identifiable {
    let id = UUID()
    let label: AnyView
    let backgroundColor: Color
    let action: () -> Void
    let enabled: Bool
    let accessibilityLabel: String

    static func text(
      label: String,
      foreground: Color,
      background: Color,
      fontName: String = "HelveticaNeue-Thin",
      fontSize: CGFloat = 20,
      action: @escaping () -> Void,
      enabled: Bool,
      accessibilityLabel: String? = nil
    ) -> KeyboardCell {
      KeyboardCell(
        label: AnyView(
          Text(label)
            .font(.custom(fontName, size: fontSize))
            .foregroundColor(foreground)
        ),
        backgroundColor: background,
        action: action,
        enabled: enabled,
        accessibilityLabel: accessibilityLabel ?? label
      )
    }

    static func image(
      imageName: String,
      background: Color,
      action: @escaping () -> Void,
      enabled: Bool,
      accessibilityLabel: String
    ) -> KeyboardCell {
      KeyboardCell(
        label: AnyView(
          Group {
            if let uiImage = UIImage(
              named: imageName,
              in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
              compatibleWith: nil
            ) {
              Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .padding(8)
            } else {
              Image(systemName: "questionmark.square.dashed")
            }
          }
        ),
        backgroundColor: background,
        action: action,
        enabled: enabled,
        accessibilityLabel: accessibilityLabel
      )
    }

    static func number(_ value: String, action: @escaping () -> Void, enabled: Bool) -> KeyboardCell {
      .text(
        label: value,
        foreground: .black,
        background: .numberKey,
        action: action,
        enabled: enabled
      )
    }

    static func `operator`(_ value: String, action: @escaping () -> Void, enabled: Bool) -> KeyboardCell {
      .text(
        label: value,
        foreground: .black,
        background: .operatorKey,
        action: action,
        enabled: enabled
      )
    }
  }

  private extension Color {
    static let numberKey = Color(white: 0.95)
    static let operatorKey = Color(red: 0.99, green: 0.90, blue: 0.78)
    static let blueKey = Color(red: 0.57, green: 0.78, blue: 0.95)
    static let highlightBlue = Color(red: 0.41, green: 0.65, blue: 0.90)
    static let utilityKey = Color(red: 0.53, green: 0.53, blue: 0.55)
  }

#endif

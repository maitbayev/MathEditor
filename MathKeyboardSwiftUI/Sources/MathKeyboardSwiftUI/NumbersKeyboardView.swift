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
    
    private var keyboardState: KeyboardState {
      KeyboardState(
        currentTab: .numbers,
        equalsAllowed: model.equalsAllowed,
        fractionsAllowed: model.fractionsAllowed,
        variablesAllowed: model.variablesAllowed,
        numbersAllowed: model.numbersAllowed,
        operatorsAllowed: model.operatorsAllowed,
        exponentHighlighted: model.exponentHighlighted,
        squareRootHighlighted: false,
        radicalHighlighted: false
      )
    }

    var body: some View {
      GeometryReader { proxy in
        let totalWidth = proxy.size.width
        let totalHeight = proxy.size.height
        let utilityWidth = totalWidth * 0.225
        let standardColumnWidth = (totalWidth - utilityWidth) / 5
        let rowHeight = totalHeight / 4

        ZStack {
          assetImage("Numbers Keyboard")
            .resizable()
            .frame(width: totalWidth, height: totalHeight)

          HStack(spacing: 0) {
            VStack(spacing: 0) {
              keyButton(featureItems[0]).frame(width: standardColumnWidth, height: rowHeight)
              keyButton(featureItems[1]).frame(width: standardColumnWidth, height: rowHeight)
              keyButton(featureItems[2]).frame(width: standardColumnWidth, height: rowHeight)
              keyButton(featureItems[3]).frame(width: standardColumnWidth, height: rowHeight)
            }
            mainColumnsSection(columnWidth: standardColumnWidth, rowHeight: rowHeight)
            VStack(spacing: 0) {
              keyButton(utilityBackspace).frame(width: utilityWidth, height: rowHeight)
              keyButton(utilityEnter).frame(width: utilityWidth, height: rowHeight * 2)
              keyButton(utilityDismiss).frame(width: utilityWidth, height: rowHeight)
            }
          }
        }
        .frame(width: totalWidth, height: totalHeight)
      }
    }

    // 2) Main four-column block (numbers left/middle/right + operators) using Grid
    private func mainColumnsSection(columnWidth: CGFloat, rowHeight: CGFloat) -> some View {
      let columns = [numbersLeftItems, numbersMiddleItems, numbersRightItems, operatorItems]
      Grid(horizontalSpacing: 0, verticalSpacing: 0) {
        ForEach(0..<4, id: \.self) { row in
          GridRow {
            ForEach(0..<4, id: \.self) { column in
              keyButton(columns[column][row])
                .frame(width: columnWidth, height: rowHeight)
            }
          }
        }
      }
    }

    private func keyButton(_ cell: KeyboardCell) -> some View {
      Button(action: cell.action) {
        ZStack {
          Rectangle().fill(Color.white.opacity(0.001))
          if let overlayAsset = cell.overlayAsset {
            assetImage(overlayAsset)
              .resizable()
          }
          cell.label
        }
      }
      .buttonStyle(.plain)
      .disabled(!cell.enabled)
      .opacity(cell.enabled ? 1 : 0.75)
      .accessibilityLabel(cell.accessibilityLabel)
    }

    private var featureItems: [KeyboardCell] {
      [
        .text(
          label: "x", foreground: .white, fontName: KeyboardFontRegistry.variableFontName,
          action: { onInsertText("x") }, enabled: keyboardState.variablesAllowed),
        .text(
          label: "y", foreground: .white, fontName: KeyboardFontRegistry.variableFontName,
          action: { onInsertText("y") }, enabled: keyboardState.variablesAllowed),
        .image(
          imageName: "Fraction",
          action: { onInsertText(MTSymbolFractionSlash) }, enabled: keyboardState.fractionsAllowed,
          accessibilityLabel: "Fraction"),
        .image(
          imageName: "Exponent",
          action: { onInsertText("^") }, enabled: true, accessibilityLabel: "Exponent",
          overlayAsset: keyboardState.exponentHighlighted ? "blue-button-highlighted" : nil),
      ]
    }

    private var numbersLeftItems: [KeyboardCell] {
      [
        .text(label: "7", foreground: .black, action: { onInsertText("7") }, enabled: keyboardState.numbersAllowed),
        .text(label: "4", foreground: .black, action: { onInsertText("4") }, enabled: keyboardState.numbersAllowed),
        .text(label: "1", foreground: .black, action: { onInsertText("1") }, enabled: keyboardState.numbersAllowed),
        .text(label: "0", foreground: .black, action: { onInsertText("0") }, enabled: keyboardState.numbersAllowed),
      ]
    }

    private var numbersMiddleItems: [KeyboardCell] {
      [
        .text(label: "8", foreground: .black, action: { onInsertText("8") }, enabled: keyboardState.numbersAllowed),
        .text(label: "5", foreground: .black, action: { onInsertText("5") }, enabled: keyboardState.numbersAllowed),
        .text(label: "2", foreground: .black, action: { onInsertText("2") }, enabled: keyboardState.numbersAllowed),
        .text(label: ".", foreground: .black, action: { onInsertText(".") }, enabled: keyboardState.numbersAllowed),
      ]
    }

    private var numbersRightItems: [KeyboardCell] {
      [
        .text(label: "9", foreground: .black, action: { onInsertText("9") }, enabled: keyboardState.numbersAllowed),
        .text(label: "6", foreground: .black, action: { onInsertText("6") }, enabled: keyboardState.numbersAllowed),
        .text(label: "3", foreground: .black, action: { onInsertText("3") }, enabled: keyboardState.numbersAllowed),
        .text(
          label: "=", foreground: keyboardState.equalsAllowed ? .black : Color(white: 0.67),
          action: { onInsertText("=") }, enabled: keyboardState.equalsAllowed,
          overlayAsset: keyboardState.equalsAllowed ? nil : "num-button-disabled"),
      ]
    }

    private var operatorItems: [KeyboardCell] {
      [
        .text(label: "÷", foreground: .black, action: { onInsertText("÷") }, enabled: keyboardState.operatorsAllowed),
        .text(label: "×", foreground: .black, action: { onInsertText("×") }, enabled: keyboardState.operatorsAllowed),
        .text(label: "-", foreground: .black, action: { onInsertText("-") }, enabled: keyboardState.operatorsAllowed),
        .text(label: "+", foreground: .black, action: { onInsertText("+") }, enabled: keyboardState.operatorsAllowed),
      ]
    }

    private var utilityBackspace: KeyboardCell {
      .image(
        imageName: "Backspace",
        action: onBackspace, enabled: true, accessibilityLabel: "Backspace")
    }

    private var utilityEnter: KeyboardCell {
      .text(
        label: "Enter", foreground: .white,
        action: { onInsertText("\n") }, enabled: true)
    }

    private var utilityDismiss: KeyboardCell {
      .image(
        imageName: "Keyboard Down",
        action: onDismiss, enabled: true, accessibilityLabel: "Dismiss keyboard")
    }

    private func assetImage(_ name: String) -> Image {
      if let image = UIImage(
        named: name,
        in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
        compatibleWith: nil
      ) {
        return Image(uiImage: image)
      }
      return Image(systemName: "questionmark.square.dashed")
    }

  }

  private struct KeyboardCell: Identifiable {
    let id = UUID()
    let label: AnyView
    let action: () -> Void
    let enabled: Bool
    let accessibilityLabel: String
    let overlayAsset: String?

    static func text(
      label: String,
      foreground: Color,
      fontName: String = "HelveticaNeue-Thin",
      fontSize: CGFloat = 20,
      action: @escaping () -> Void,
      enabled: Bool,
      accessibilityLabel: String? = nil,
      overlayAsset: String? = nil
    ) -> KeyboardCell {
      KeyboardCell(
        label: AnyView(
          Text(label)
            .font(.custom(fontName, size: fontSize))
            .foregroundColor(foreground)
        ),
        action: action,
        enabled: enabled,
        accessibilityLabel: accessibilityLabel ?? label,
        overlayAsset: overlayAsset
      )
    }

    static func image(
      imageName: String,
      action: @escaping () -> Void,
      enabled: Bool,
      accessibilityLabel: String,
      overlayAsset: String? = nil
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
        action: action,
        enabled: enabled,
        accessibilityLabel: accessibilityLabel,
        overlayAsset: overlayAsset
      )
    }

  }

#endif

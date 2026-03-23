#if os(iOS)

  import MathEditor
  import MathKeyboard
  import SwiftUI
  import CoreText
  import Foundation
  import UIKit

  protocol KeyboardConfigurable: AnyObject {
    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?)
    func applyKeyboardState(_ state: KeyboardState)
  }

  extension MTKeyboard: KeyboardConfigurable {
    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?) {
      self.textView = textView
    }

    func applyKeyboardState(_ state: KeyboardState) {
      setNumbersState(state.numbersAllowed)
      setOperatorState(state.operatorsAllowed)
      setVariablesState(state.variablesAllowed)
      setFractionState(state.fractionsAllowed)
      setEqualsState(state.equalsAllowed)
      setExponentState(state.exponentHighlighted)
      setSquareRootState(state.squareRootHighlighted)
      setRadicalState(state.radicalHighlighted)
    }
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
    private var keyboardState = KeyboardState()
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

    func applyKeyboardState(_ state: KeyboardState) {
      updateState { $0 = state }
    }

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
        keyboardState: keyboardState,
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

    private func updateState(_ update: @escaping (inout KeyboardState) -> Void) {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        let previousState = self.keyboardState
        update(&self.keyboardState)
        guard self.keyboardState != previousState else { return }
        self.hostingController.rootView = self.makeRootView()
      }
    }
  }

  struct NumbersKeyboardView: View {
    let keyboardState: KeyboardState
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
          cellContentView(cell)
        }
      }
      .buttonStyle(
        KeyboardPressStyle(
          pressedOverlay: AnyView(
            Group {
              if let pressedAsset = cell.pressedAsset {
                assetImage(pressedAsset)
                  .resizable()
                  .opacity(0.65)
              } else {
                Color.clear
              }
            }
          )
        )
      )
      .disabled(!cell.enabled)
      .opacity(cell.enabled ? 1 : 0.75)
      .accessibilityLabel(cell.accessibilityLabel)
    }

    private var featureItems: [KeyboardCell] {
      [
        .text(
          label: "x", tone: .light, fontName: KeyboardFontRegistry.variableFontName,
          action: { onInsertText("x") }, enabled: keyboardState.variablesAllowed,
          pressedAsset: "Keyboard-marine-pressed"),
        .text(
          label: "y", tone: .light, fontName: KeyboardFontRegistry.variableFontName,
          action: { onInsertText("y") }, enabled: keyboardState.variablesAllowed,
          pressedAsset: "Keyboard-marine-pressed"),
        .image(
          imageName: "Fraction",
          action: { onInsertText(MTSymbolFractionSlash) }, enabled: keyboardState.fractionsAllowed,
          accessibilityLabel: "Fraction",
          pressedAsset: "Keyboard-marine-pressed"),
        .image(
          imageName: "Exponent",
          action: { onInsertText("^") }, enabled: true, accessibilityLabel: "Exponent",
          pressedAsset: "Keyboard-marine-pressed",
          overlayAsset: keyboardState.exponentHighlighted ? "blue-button-highlighted" : nil),
      ]
    }

    private var numbersLeftItems: [KeyboardCell] {
      [
        .text(label: "7", tone: .dark, action: { onInsertText("7") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "4", tone: .dark, action: { onInsertText("4") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "1", tone: .dark, action: { onInsertText("1") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "0", tone: .dark, action: { onInsertText("0") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      ]
    }

    private var numbersMiddleItems: [KeyboardCell] {
      [
        .text(label: "8", tone: .dark, action: { onInsertText("8") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "5", tone: .dark, action: { onInsertText("5") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "2", tone: .dark, action: { onInsertText("2") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: ".", tone: .dark, action: { onInsertText(".") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      ]
    }

    private var numbersRightItems: [KeyboardCell] {
      [
        .text(label: "9", tone: .dark, action: { onInsertText("9") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "6", tone: .dark, action: { onInsertText("6") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(label: "3", tone: .dark, action: { onInsertText("3") }, enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
        .text(
          label: "=", tone: keyboardState.equalsAllowed ? .dark : .disabled,
          action: { onInsertText("=") }, enabled: keyboardState.equalsAllowed,
          pressedAsset: "Keyboard-grey-pressed",
          overlayAsset: keyboardState.equalsAllowed ? nil : "num-button-disabled"),
      ]
    }

    private var operatorItems: [KeyboardCell] {
      [
        .text(label: "÷", tone: .dark, action: { onInsertText("÷") }, enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
        .text(label: "×", tone: .dark, action: { onInsertText("×") }, enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
        .text(label: "-", tone: .dark, action: { onInsertText("-") }, enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
        .text(label: "+", tone: .dark, action: { onInsertText("+") }, enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      ]
    }

    private var utilityBackspace: KeyboardCell {
      .image(
        imageName: "Backspace",
        action: onBackspace, enabled: true, accessibilityLabel: "Backspace",
        pressedAsset: "Keyboard-grey-pressed")
    }

    private var utilityEnter: KeyboardCell {
      .text(
        label: "Enter", tone: .light,
        action: { onInsertText("\n") }, enabled: true, pressedAsset: "Keyboard-grey-pressed")
    }

    private var utilityDismiss: KeyboardCell {
      .image(
        imageName: "Keyboard Down",
        action: onDismiss, enabled: true, accessibilityLabel: "Dismiss keyboard",
        pressedAsset: "Keyboard-grey-pressed")
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
    
    @ViewBuilder
    private func cellContentView(_ cell: KeyboardCell) -> some View {
      switch cell.content {
      case .text(let text):
        Text(text.value)
          .font(.custom(text.fontName, size: text.fontSize))
          .foregroundColor(textColor(for: text.tone))
      case .image(let image):
        if let uiImage = UIImage(
          named: image.name,
          in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
          compatibleWith: nil
        ) {
          Image(uiImage: uiImage)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .padding(image.padding)
        } else {
          Image(systemName: "questionmark.square.dashed")
        }
      }
    }
    
    private func textColor(for tone: KeyboardCell.TextTone) -> Color {
      switch tone {
      case .light: .white
      case .dark: .black
      case .disabled: Color(white: 0.67)
      }
    }

  }

  private struct KeyboardCell: Identifiable {
    enum Content {
      case text(TextContent)
      case image(ImageContent)
    }

    struct TextContent {
      let value: String
      let fontName: String
      let fontSize: CGFloat
      let tone: TextTone
    }

    struct ImageContent {
      let name: String
      let padding: CGFloat
    }

    enum TextTone {
      case light
      case dark
      case disabled
    }

    let id = UUID()
    let content: Content
    let action: () -> Void
    let enabled: Bool
    let accessibilityLabel: String
    let pressedAsset: String?
    let overlayAsset: String?

    static func text(
      label: String,
      tone: TextTone,
      fontName: String = "HelveticaNeue-Thin",
      fontSize: CGFloat = 20,
      action: @escaping () -> Void,
      enabled: Bool,
      accessibilityLabel: String? = nil,
      pressedAsset: String? = nil,
      overlayAsset: String? = nil
    ) -> KeyboardCell {
      KeyboardCell(
        content: .text(
          TextContent(
            value: label,
            fontName: fontName,
            fontSize: fontSize,
            tone: tone
          )
        ),
        action: action,
        enabled: enabled,
        accessibilityLabel: accessibilityLabel ?? label,
        pressedAsset: pressedAsset,
        overlayAsset: overlayAsset
      )
    }

    static func image(
      imageName: String,
      action: @escaping () -> Void,
      enabled: Bool,
      accessibilityLabel: String,
      pressedAsset: String? = nil,
      overlayAsset: String? = nil
    ) -> KeyboardCell {
      KeyboardCell(
        content: .image(ImageContent(name: imageName, padding: 8)),
        action: action,
        enabled: enabled,
        accessibilityLabel: accessibilityLabel,
        pressedAsset: pressedAsset,
        overlayAsset: overlayAsset
      )
    }

  }

  private struct KeyboardPressStyle: ButtonStyle {
    let pressedOverlay: AnyView

    func makeBody(configuration: Configuration) -> some View {
      ZStack {
        if configuration.isPressed {
          pressedOverlay
        }
        configuration.label
      }
    }
  }

#endif

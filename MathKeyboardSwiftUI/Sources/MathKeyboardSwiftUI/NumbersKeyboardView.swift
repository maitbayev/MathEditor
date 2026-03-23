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

  enum NumbersKeyboardLayout {
    case legacy
    case equalGrid
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
    private let layout: NumbersKeyboardLayout
    private weak var editingTarget: (any UIView & UIKeyInput)?
    private lazy var hostingController = UIHostingController(rootView: makeRootView())

    init(layout: NumbersKeyboardLayout, frame: CGRect = .zero) {
      self.layout = layout
      super.init(frame: frame)
      commonInit()
    }

    required init?(coder: NSCoder) {
      layout = .legacy
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
        layout: layout,
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
    let layout: NumbersKeyboardLayout
    let onInsertText: (String) -> Void
    let onBackspace: () -> Void
    let onDismiss: () -> Void

    private let canvasSize = CGSize(width: 320, height: 180)

    var body: some View {
      GeometryReader { proxy in
        stretchedKeyboardCanvas(in: proxy.size)
          .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
          .clipped()
      }
    }

    private func stretchedKeyboardCanvas(in size: CGSize) -> some View {
      ZStack(alignment: .topLeading) {
        assetImage("Numbers Keyboard")
          .resizable()
          .frame(width: size.width, height: size.height)

        if model.exponentHighlighted {
          stretchedOverlayImage(
            "blue-button-highlighted", frame: keyboardFrame(column: .feature, row: .bottom), in: size)
        }

        if !model.equalsAllowed {
          stretchedOverlayImage(
            "num-button-disabled", frame: keyboardFrame(column: .numbersRight, row: .bottom),
            in: size)
        }

        ForEach(keys) { key in
          stretchedTappableKey(key, in: size)
        }

        ForEach(labels) { label in
          stretchedKeyboardLabel(label, in: size)
        }
      }
    }

    private var keys: [KeyboardKey] {
      [
        .text(
          "x", action: { onInsertText("x") }, frame: keyboardFrame(column: .feature, row: .top),
          enabled: model.variablesAllowed),
        .text(
          "y", action: { onInsertText("y") },
          frame: keyboardFrame(column: .feature, row: .upperMiddle), enabled: model.variablesAllowed
        ),
        .custom(
          action: { onInsertText(MTSymbolFractionSlash) },
          frame: keyboardFrame(column: .feature, row: .lowerMiddle),
          enabled: model.fractionsAllowed, pressedAsset: "Keyboard-marine-pressed",
          accessibilityLabel: "Fraction"),
        .custom(
          action: { onInsertText("^") }, frame: keyboardFrame(column: .feature, row: .bottom),
          enabled: true, pressedAsset: "Keyboard-marine-pressed", accessibilityLabel: "Exponent"),

        .text(
          "7", action: { onInsertText("7") }, frame: keyboardFrame(column: .numbersLeft, row: .top),
          enabled: model.numbersAllowed),
        .text(
          "8", action: { onInsertText("8") },
          frame: keyboardFrame(column: .numbersMiddle, row: .top), enabled: model.numbersAllowed),
        .text(
          "9", action: { onInsertText("9") },
          frame: keyboardFrame(column: .numbersRight, row: .top), enabled: model.numbersAllowed),
        .text(
          "4", action: { onInsertText("4") },
          frame: keyboardFrame(column: .numbersLeft, row: .upperMiddle),
          enabled: model.numbersAllowed),
        .text(
          "5", action: { onInsertText("5") },
          frame: keyboardFrame(column: .numbersMiddle, row: .upperMiddle),
          enabled: model.numbersAllowed),
        .text(
          "6", action: { onInsertText("6") },
          frame: keyboardFrame(column: .numbersRight, row: .upperMiddle),
          enabled: model.numbersAllowed),
        .text(
          "1", action: { onInsertText("1") },
          frame: keyboardFrame(column: .numbersLeft, row: .lowerMiddle),
          enabled: model.numbersAllowed),
        .text(
          "2", action: { onInsertText("2") },
          frame: keyboardFrame(column: .numbersMiddle, row: .lowerMiddle),
          enabled: model.numbersAllowed),
        .text(
          "3", action: { onInsertText("3") },
          frame: keyboardFrame(column: .numbersRight, row: .lowerMiddle),
          enabled: model.numbersAllowed),
        .text(
          "0", action: { onInsertText("0") },
          frame: keyboardFrame(column: .numbersLeft, row: .bottom), enabled: model.numbersAllowed),
        .text(
          ".", action: { onInsertText(".") },
          frame: keyboardFrame(column: .numbersMiddle, row: .bottom), enabled: model.numbersAllowed),
        .text(
          "=", action: { onInsertText("=") },
          frame: keyboardFrame(column: .numbersRight, row: .bottom), enabled: model.equalsAllowed),
        .text(
          "÷", action: { onInsertText("÷") }, frame: keyboardFrame(column: .operators, row: .top),
          enabled: model.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
        .text(
          "×", action: { onInsertText("×") },
          frame: keyboardFrame(column: .operators, row: .upperMiddle),
          enabled: model.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
        .text(
          "-", action: { onInsertText("-") },
          frame: keyboardFrame(column: .operators, row: .lowerMiddle),
          enabled: model.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
        .text(
          "+", action: { onInsertText("+") },
          frame: keyboardFrame(column: .operators, row: .bottom), enabled: model.operatorsAllowed,
          pressedAsset: "Keyboard-orange-pressed"),
        .custom(
          action: onBackspace, frame: keyboardFrame(column: .utility, row: .top), enabled: true,
          pressedAsset: "Keyboard-grey-pressed", accessibilityLabel: "Backspace"),
        .custom(
          action: { onInsertText("\n") },
          frame: keyboardFrame(column: .utility, row: .upperMiddle, rowSpan: 2), enabled: true,
          pressedAsset: "Keyboard-grey-pressed", accessibilityLabel: "Enter"),
        .custom(
          action: onDismiss, frame: keyboardFrame(column: .utility, row: .bottom), enabled: true,
          pressedAsset: "Keyboard-grey-pressed", accessibilityLabel: "Dismiss keyboard"),
      ]
    }

    private var labels: [KeyboardLabel] {
      [
        .text(
          "x", frame: keyboardFrame(column: .feature, row: .top), color: .white,
          fontName: KeyboardFontRegistry.variableFontName, fontSize: 20, bottomInset: 10),
        .text(
          "y", frame: keyboardFrame(column: .feature, row: .upperMiddle), color: .white,
          fontName: KeyboardFontRegistry.variableFontName, fontSize: 20, bottomInset: 10),
        .image(
          "Fraction", frame: keyboardFrame(column: .feature, row: .lowerMiddle),
          imageInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)),
        .image(
          "Exponent", frame: keyboardFrame(column: .feature, row: .bottom), imageInsets: .zero),

        .text(
          "7", frame: keyboardFrame(column: .numbersLeft, row: .top), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "8", frame: keyboardFrame(column: .numbersMiddle, row: .top), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "9", frame: keyboardFrame(column: .numbersRight, row: .top), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "4", frame: keyboardFrame(column: .numbersLeft, row: .upperMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "5", frame: keyboardFrame(column: .numbersMiddle, row: .upperMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "6", frame: keyboardFrame(column: .numbersRight, row: .upperMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "1", frame: keyboardFrame(column: .numbersLeft, row: .lowerMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "2", frame: keyboardFrame(column: .numbersMiddle, row: .lowerMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "3", frame: keyboardFrame(column: .numbersRight, row: .lowerMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "0", frame: keyboardFrame(column: .numbersLeft, row: .bottom), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          ".", frame: keyboardFrame(column: .numbersMiddle, row: .bottom), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20),
        .text(
          "=", frame: keyboardFrame(column: .numbersRight, row: .bottom),
          color: model.equalsAllowed ? .black : Color(white: 0.67), fontName: "HelveticaNeue-Thin",
          fontSize: 25, bottomInset: 2),
        .text(
          "÷", frame: keyboardFrame(column: .operators, row: .top), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20, bottomInset: 5),
        .text(
          "×", frame: keyboardFrame(column: .operators, row: .upperMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20, bottomInset: 7),
        .text(
          "-", frame: keyboardFrame(column: .operators, row: .lowerMiddle), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 25, bottomInset: 9),
        .text(
          "+", frame: keyboardFrame(column: .operators, row: .bottom), color: .black,
          fontName: "HelveticaNeue-Thin", fontSize: 20, bottomInset: 5),
        .image("Backspace", frame: keyboardFrame(column: .utility, row: .top), imageInsets: .zero),
        .text(
          "Enter", frame: keyboardFrame(column: .utility, row: .upperMiddle, rowSpan: 2),
          color: .white, fontName: "HelveticaNeue-Light", fontSize: 20),
        .image(
          "Keyboard Down", frame: keyboardFrame(column: .utility, row: .bottom),
          imageInsets: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0),
          imageOffset: CGSize(width: 0, height: -1.5)),
      ]
    }

    private func keyboardFrame(
      column: KeyboardColumn,
      row: KeyboardRow,
      rowSpan: CGFloat = 1,
      width: CGFloat? = nil
    ) -> CGRect {
      CGRect(
        x: column.layout(layout).x,
        y: row.y,
        width: width ?? column.layout(layout).width,
        height: row.height * rowSpan
      )
    }

    private func stretchedTappableKey(_ key: KeyboardKey, in size: CGSize) -> some View {
      StretchedKeyboardButton(
        key: key,
        canvasSize: canvasSize,
        containerSize: size,
        pressedOverlay: {
          if let asset = key.pressedAsset {
            assetImage(asset)
              .resizable()
          } else {
            Color.clear
          }
        }
      )
    }

    private func stretchedOverlayImage(_ name: String, frame: CGRect, in size: CGSize) -> some View
    {
      assetImage(name)
        .resizable()
        .frame(
          width: scaledWidth(frame.width, in: size), height: scaledHeight(frame.height, in: size)
        )
        .position(
          x: scaled(frame.midX, from: canvasSize.width, to: size.width),
          y: scaled(frame.midY, from: canvasSize.height, to: size.height)
        )
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func stretchedKeyboardLabel(_ label: KeyboardLabel, in size: CGSize) -> some View {
      switch label.content {
      case .text(let style):
        Text(style.value)
          .font(.custom(style.fontName, size: style.fontSize))
          .foregroundColor(style.color)
          .frame(
            width: scaledWidth(label.frame.width, in: size),
            height: scaledHeight(label.frame.height, in: size)
          )
          .position(
            x: scaled(
              label.frame.midX + style.offset.width, from: canvasSize.width, to: size.width),
            y: scaled(
              label.frame.midY + style.offset.height, from: canvasSize.height, to: size.height)
              - (style.bottomInset / 2)
          )
          .allowsHitTesting(false)

      case .image(let style):
        if let image = assetUIImage(style.name) {
          let contentWidth = scaled(
            label.frame.width - style.insets.left - style.insets.right, from: canvasSize.width,
            to: size.width)
          let contentHeight = scaled(
            label.frame.height - style.insets.top - style.insets.bottom, from: canvasSize.height,
            to: size.height)
          let intrinsicWidth = image.size.width
          let intrinsicHeight = image.size.height
          let fitScale = min(contentWidth / intrinsicWidth, contentHeight / intrinsicHeight, 1)
          let renderedWidth = intrinsicWidth * fitScale
          let renderedHeight = intrinsicHeight * fitScale

          Image(uiImage: image)
            .renderingMode(.original)
            .resizable()
            .frame(width: renderedWidth, height: renderedHeight)
            .position(
              x: scaled(
                label.frame.midX + style.offset.width, from: canvasSize.width, to: size.width),
              y: scaled(
                label.frame.midY + style.offset.height, from: canvasSize.height, to: size.height)
            )
            .allowsHitTesting(false)
        }
      }
    }

    private func assetImage(_ name: String) -> Image {
      if let image = assetUIImage(name) {
        return Image(uiImage: image)
      }
      return Image(systemName: "questionmark.square.dashed")
    }

    private func assetUIImage(_ name: String) -> UIImage? {
      UIImage(
        named: name,
        in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
        compatibleWith: nil
      )
    }

    private func scaled(_ value: CGFloat, from source: CGFloat, to target: CGFloat) -> CGFloat {
      (value / source) * target
    }

    private func scaledWidth(_ value: CGFloat, in size: CGSize) -> CGFloat {
      scaled(value, from: canvasSize.width, to: size.width)
    }

    private func scaledHeight(_ value: CGFloat, in size: CGSize) -> CGFloat {
      scaled(value, from: canvasSize.height, to: size.height)
    }
  }

  private enum KeyboardColumn {
    case feature
    case numbersLeft
    case numbersMiddle
    case numbersRight
    case operators
    case utility

    struct Frame {
      let x: CGFloat
      let width: CGFloat
    }

    func layout(_ mode: NumbersKeyboardLayout) -> Frame {
      switch mode {
      case .legacy:
        switch self {
        case .feature: Frame(x: 0, width: 49.6667)
        case .numbersLeft: Frame(x: 50, width: 49)
        case .numbersMiddle: Frame(x: 99.6667, width: 49.6667)
        case .numbersRight: Frame(x: 149.3333, width: 49.6667)
        case .operators: Frame(x: 199, width: 49)
        case .utility: Frame(x: 248, width: 72)
        }
      case .equalGrid:
        switch self {
        case .feature: Frame(x: 0, width: 49.6)
        case .numbersLeft: Frame(x: 49.6, width: 49.6)
        case .numbersMiddle: Frame(x: 99.2, width: 49.6)
        case .numbersRight: Frame(x: 148.8, width: 49.6)
        case .operators: Frame(x: 198.4, width: 49.6)
        case .utility: Frame(x: 248, width: 72)
        }
      }
    }
  }

  private enum KeyboardRow {
    case top
    case upperMiddle
    case lowerMiddle
    case bottom

    var y: CGFloat {
      switch self {
      case .top: 0
      case .upperMiddle: 45
      case .lowerMiddle: 90
      case .bottom: 135
      }
    }

    var height: CGFloat { 45 }
  }

  private struct KeyboardKey: Identifiable {
    let id = UUID()
    let action: () -> Void
    let frame: CGRect
    let enabled: Bool
    let pressedAsset: String?
    let accessibilityLabel: String

    static func text(
      _ label: String,
      action: @escaping () -> Void,
      frame: CGRect,
      enabled: Bool,
      pressedAsset: String = "Keyboard-grey-pressed"
    ) -> KeyboardKey {
      KeyboardKey(
        action: action,
        frame: frame,
        enabled: enabled,
        pressedAsset: pressedAsset,
        accessibilityLabel: label
      )
    }

    static func custom(
      action: @escaping () -> Void,
      frame: CGRect,
      enabled: Bool,
      pressedAsset: String,
      accessibilityLabel: String
    ) -> KeyboardKey {
      KeyboardKey(
        action: action,
        frame: frame,
        enabled: enabled,
        pressedAsset: pressedAsset,
        accessibilityLabel: accessibilityLabel
      )
    }
  }

  private struct KeyboardLabel: Identifiable {
    enum Content {
      case text(TextStyle)
      case image(ImageStyle)
    }

    struct TextStyle {
      let value: String
      let color: Color
      let fontName: String
      let fontSize: CGFloat
      let bottomInset: CGFloat
      let offset: CGSize
    }

    struct ImageStyle {
      let name: String
      let insets: UIEdgeInsets
      let offset: CGSize
    }

    let id = UUID()
    let content: Content
    let frame: CGRect

    static func text(
      _ value: String,
      frame: CGRect,
      color: Color,
      fontName: String,
      fontSize: CGFloat,
      bottomInset: CGFloat = 0,
      offset: CGSize = .zero
    ) -> KeyboardLabel {
      KeyboardLabel(
        content: .text(
          TextStyle(
            value: value,
            color: color,
            fontName: fontName,
            fontSize: fontSize,
            bottomInset: bottomInset,
            offset: offset
          )
        ),
        frame: frame
      )
    }

    static func image(
      _ name: String,
      frame: CGRect,
      imageInsets: UIEdgeInsets,
      imageOffset: CGSize = .zero
    ) -> KeyboardLabel {
      KeyboardLabel(
        content: .image(
          ImageStyle(
            name: name,
            insets: imageInsets,
            offset: imageOffset
          )
        ),
        frame: frame
      )
    }
  }

  private struct StretchedKeyboardButton<PressedOverlay: View>: View {
    let key: KeyboardKey
    let canvasSize: CGSize
    let containerSize: CGSize
    @ViewBuilder let pressedOverlay: () -> PressedOverlay

    var body: some View {
      Button(action: key.action) {
        Rectangle()
          .fill(Color.white.opacity(0.001))
          .contentShape(Rectangle())
      }
      .buttonStyle(
        KeyboardTapTargetStyle(
          pressedOverlay: AnyView(pressedOverlay())
        )
      )
      .disabled(!key.enabled)
      .frame(
        width: scaled(key.frame.width, from: canvasSize.width, to: containerSize.width),
        height: scaled(key.frame.height, from: canvasSize.height, to: containerSize.height)
      )
      .position(
        x: scaled(key.frame.midX, from: canvasSize.width, to: containerSize.width),
        y: scaled(key.frame.midY, from: canvasSize.height, to: containerSize.height)
      )
      .accessibility(label: Text(key.accessibilityLabel))
    }

    private func scaled(_ value: CGFloat, from source: CGFloat, to target: CGFloat) -> CGFloat {
      (value / source) * target
    }
  }

  private struct KeyboardTapTargetStyle: ButtonStyle {
    let pressedOverlay: AnyView

    func makeBody(configuration: Configuration) -> some View {
      ZStack {
        configuration.label
        if configuration.isPressed {
          pressedOverlay
        }
      }
    }
  }

#endif

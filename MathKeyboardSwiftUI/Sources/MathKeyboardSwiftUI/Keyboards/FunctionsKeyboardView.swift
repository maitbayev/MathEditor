import Foundation
import MathEditor
import SwiftUI

func functionsKeyboardView(
  state: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> MainKeyboardView {
  MainKeyboardView(
    backgroundImageName: "Functions Keyboard",
    middleColumns: makeFunctionsGrid(state: state, onAction: onAction),
    state: state,
    onAction: onAction
  )
}

private func makeFunctionsGrid(
  state: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> [[KeyboardCell]] {
  let trigLeftItems: [KeyboardCell] = [
    .text(
      label: "sin", tone: .dark, action: { onAction(.insertText("sin")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "sec", tone: .dark, action: { onAction(.insertText("sec")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "log", tone: .dark, action: { onAction(.insertText("log")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .image(
      imageName: "Subscript",
      action: { onAction(.insertText("_")) },
      enabled: true,
      accessibilityLabel: "Subscript",
      pressedAsset: "Keyboard-green-pressed"),
  ]

  let trigMiddleItems: [KeyboardCell] = [
    .text(
      label: "cos", tone: .dark, action: { onAction(.insertText("cos")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "csc", tone: .dark, action: { onAction(.insertText("csc")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "ln", tone: .dark, action: { onAction(.insertText("ln")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .image(
      imageName: "Sqrt",
      action: { onAction(.insertText(MTSymbolSquareRoot)) },
      enabled: true,
      accessibilityLabel: "Square root",
      pressedAsset: "Keyboard-green-pressed",
      overlayAsset: state.squareRootHighlighted ? "Keyboard-green-pressed" : nil),
  ]

  let trigRightItems: [KeyboardCell] = [
    .text(
      label: "tan", tone: .dark, action: { onAction(.insertText("tan")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "cot", tone: .dark, action: { onAction(.insertText("cot")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "π", tone: .dark, fontName: "TimesNewRomanPSMT",
      action: { onAction(.insertText("π")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .image(
      imageName: "Sqrt with Power",
      action: { onAction(.insertText(MTSymbolCubeRoot)) },
      enabled: true,
      accessibilityLabel: "Root with power",
      pressedAsset: "Keyboard-green-pressed",
      overlayAsset: state.radicalHighlighted ? "Keyboard-green-pressed" : nil),
  ]

  let constantsItems: [KeyboardCell] = [
    .text(
      label: "θ", tone: .dark, fontName: "TimesNewRomanPSMT",
      action: { onAction(.insertText("θ")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "π", tone: .dark, fontName: "TimesNewRomanPSMT",
      action: { onAction(.insertText("π")) }, enabled: true,
      pressedAsset: "Keyboard-green-pressed"),
    .text(
      label: "", tone: .dark,
      action: {}, enabled: false,
      accessibilityLabel: "Unused"),
    .text(
      label: "", tone: .dark,
      action: {}, enabled: false,
      accessibilityLabel: "Unused"),
  ]

  return [trigLeftItems, trigMiddleItems, trigRightItems, constantsItems]
}

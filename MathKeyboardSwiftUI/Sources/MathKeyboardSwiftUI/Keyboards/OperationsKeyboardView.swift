import Foundation
import SwiftUI

func operationsKeyboardView(
  state: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> MainKeyboardView {
  MainKeyboardView(
    backgroundImageName: "Operations Keyboard",
    middleColumns: makeOperationsGrid(state: state, onAction: onAction),
    state: state,
    onAction: onAction
  )
}

private func makeOperationsGrid(
  state: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> [[KeyboardCell]] {
  let groupingLeftItems: [KeyboardCell] = [
    .text(
      label: "(", tone: .dark, action: { onAction(.insertText("(")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "[", tone: .dark, action: { onAction(.insertText("[")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "{", tone: .dark, action: { onAction(.insertText("{")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "!", tone: .dark, action: { onAction(.insertText("!")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
  ]
  let groupingRightItems: [KeyboardCell] = [
    .text(
      label: ")", tone: .dark, action: { onAction(.insertText(")")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "]", tone: .dark, action: { onAction(.insertText("]")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "}", tone: .dark, action: { onAction(.insertText("}")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "∞", tone: .dark, action: { onAction(.insertText("∞")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
  ]
  let relationItems: [KeyboardCell] = [
    .text(
      label: "<", tone: .dark, action: { onAction(.insertText("<")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "≤", tone: .dark, action: { onAction(.insertText("≤")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "|□|", tone: .dark, action: { onAction(.insertText("||")) }, enabled: true,
      accessibilityLabel: "Absolute value", pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: ":", tone: .dark, action: { onAction(.insertText(":")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
  ]
  let punctuationItems: [KeyboardCell] = [
    .text(
      label: ">", tone: .dark, action: { onAction(.insertText(">")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "≥", tone: .dark, action: { onAction(.insertText("≥")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "%", tone: .dark, action: { onAction(.insertText("%")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: ",", tone: .dark, action: { onAction(.insertText(",")) }, enabled: true,
      pressedAsset: "Keyboard-orange-pressed"),
  ]
  return [groupingLeftItems, groupingRightItems, relationItems, punctuationItems]
}

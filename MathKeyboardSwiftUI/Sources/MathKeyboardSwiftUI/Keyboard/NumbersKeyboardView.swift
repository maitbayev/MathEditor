import Foundation
import SwiftUI

func numbersKeyboardView(
  state: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> MainKeyboardView {
  MainKeyboardView(
    backgroundImageName: "Numbers Keyboard",
    middleColumns: makeNumbersGrid(state: state, onAction: onAction),
    state: state,
    onAction: onAction
  )
}

private func makeNumbersGrid(
  state: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> [[KeyboardCell]] {
  let numbersLeftItems: [KeyboardCell] = [
    .text(
      label: "7", tone: .dark, action: { onAction(.insertText("7")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "4", tone: .dark, action: { onAction(.insertText("4")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "1", tone: .dark, action: { onAction(.insertText("1")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "0", tone: .dark, action: { onAction(.insertText("0")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
  ]
  let numbersMiddleItems: [KeyboardCell] = [
    .text(
      label: "8", tone: .dark, action: { onAction(.insertText("8")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "5", tone: .dark, action: { onAction(.insertText("5")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "2", tone: .dark, action: { onAction(.insertText("2")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: ".", tone: .dark, action: { onAction(.insertText(".")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
  ]
  let numbersRightItems: [KeyboardCell] = [
    .text(
      label: "9", tone: .dark, action: { onAction(.insertText("9")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "6", tone: .dark, action: { onAction(.insertText("6")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "3", tone: .dark, action: { onAction(.insertText("3")) },
      enabled: state.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    .text(
      label: "=", tone: state.equalsAllowed ? .dark : .disabled,
      action: { onAction(.insertText("=")) }, enabled: state.equalsAllowed,
      pressedAsset: "Keyboard-grey-pressed",
      overlayAsset: state.equalsAllowed ? nil : "num-button-disabled"),
  ]
  let operatorItems: [KeyboardCell] = [
    .text(
      label: "÷", tone: .dark, action: { onAction(.insertText("÷")) },
      enabled: state.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "×", tone: .dark, action: { onAction(.insertText("×")) },
      enabled: state.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "-", tone: .dark, action: { onAction(.insertText("-")) },
      enabled: state.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
    .text(
      label: "+", tone: .dark, action: { onAction(.insertText("+")) },
      enabled: state.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
  ]
  return [numbersLeftItems, numbersMiddleItems, numbersRightItems, operatorItems]
}

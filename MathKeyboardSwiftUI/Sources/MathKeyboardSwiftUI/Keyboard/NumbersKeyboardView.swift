import Foundation
import SwiftUI

struct NumbersKeyboardView: View {
  let keyboardState: KeyboardState
  let onAction: (KeyboardAction) -> Void

  private var utilityItems: KeyboardUtilityItems {
    commonUtilityItems(onAction: onAction)
  }

  var body: some View {
    KeyboardBaseLayoutView(
      backgroundImageName: "Numbers Keyboard",
      featureItems: commonFeatureItems(keyboardState: keyboardState, onAction: onAction),
      middleColumns: [numbersLeftItems, numbersMiddleItems, numbersRightItems, operatorItems],
      utilityBackspace: utilityItems.backspace,
      utilityEnter: utilityItems.enter,
      utilityDismiss: utilityItems.dismiss
    )
  }

  private var numbersLeftItems: [KeyboardCell] {
    [
      .text(
        label: "7", tone: .dark, action: { onAction(.insertText("7")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "4", tone: .dark, action: { onAction(.insertText("4")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "1", tone: .dark, action: { onAction(.insertText("1")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "0", tone: .dark, action: { onAction(.insertText("0")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    ]
  }

  private var numbersMiddleItems: [KeyboardCell] {
    [
      .text(
        label: "8", tone: .dark, action: { onAction(.insertText("8")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "5", tone: .dark, action: { onAction(.insertText("5")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "2", tone: .dark, action: { onAction(.insertText("2")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: ".", tone: .dark, action: { onAction(.insertText(".")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    ]
  }

  private var numbersRightItems: [KeyboardCell] {
    [
      .text(
        label: "9", tone: .dark, action: { onAction(.insertText("9")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "6", tone: .dark, action: { onAction(.insertText("6")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "3", tone: .dark, action: { onAction(.insertText("3")) },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "=", tone: keyboardState.equalsAllowed ? .dark : .disabled,
        action: { onAction(.insertText("=")) }, enabled: keyboardState.equalsAllowed,
        pressedAsset: "Keyboard-grey-pressed",
        overlayAsset: keyboardState.equalsAllowed ? nil : "num-button-disabled"),
    ]
  }

  private var operatorItems: [KeyboardCell] {
    [
      .text(
        label: "÷", tone: .dark, action: { onAction(.insertText("÷")) },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      .text(
        label: "×", tone: .dark, action: { onAction(.insertText("×")) },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      .text(
        label: "-", tone: .dark, action: { onAction(.insertText("-")) },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      .text(
        label: "+", tone: .dark, action: { onAction(.insertText("+")) },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
    ]
  }
}

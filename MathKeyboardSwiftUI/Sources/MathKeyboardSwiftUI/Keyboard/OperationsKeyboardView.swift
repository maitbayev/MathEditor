import Foundation
import SwiftUI

struct OperationsKeyboardView: View {
  let keyboardState: KeyboardState
  let onAction: (KeyboardAction) -> Void

  private var utilityItems: KeyboardUtilityItems {
    commonUtilityItems(onAction: onAction)
  }

  var body: some View {
    KeyboardBaseLayoutView(
      backgroundImageName: "Operations Keyboard",
      featureItems: commonFeatureItems(keyboardState: keyboardState, onAction: onAction),
      middleColumns: [groupingLeftItems, groupingRightItems, relationItems, punctuationItems],
      utilityBackspace: utilityItems.backspace,
      utilityEnter: utilityItems.enter,
      utilityDismiss: utilityItems.dismiss
    )
  }

  private var groupingLeftItems: [KeyboardCell] {
    [
      .text(label: "(", tone: .dark, action: { onAction(.insertText("(")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "[", tone: .dark, action: { onAction(.insertText("[")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "{", tone: .dark, action: { onAction(.insertText("{")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "!", tone: .dark, action: { onAction(.insertText("!")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
    ]
  }

  private var groupingRightItems: [KeyboardCell] {
    [
      .text(label: ")", tone: .dark, action: { onAction(.insertText(")")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "]", tone: .dark, action: { onAction(.insertText("]")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "}", tone: .dark, action: { onAction(.insertText("}")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "∞", tone: .dark, action: { onAction(.insertText("∞")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
    ]
  }

  private var relationItems: [KeyboardCell] {
    [
      .text(label: "<", tone: .dark, action: { onAction(.insertText("<")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "≤", tone: .dark, action: { onAction(.insertText("≤")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "|□|", tone: .dark, action: { onAction(.insertText("||")) }, enabled: true, accessibilityLabel: "Absolute value", pressedAsset: "Keyboard-orange-pressed"),
      .text(label: ":", tone: .dark, action: { onAction(.insertText(":")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
    ]
  }

  private var punctuationItems: [KeyboardCell] {
    [
      .text(label: ">", tone: .dark, action: { onAction(.insertText(">")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "≥", tone: .dark, action: { onAction(.insertText("≥")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: "%", tone: .dark, action: { onAction(.insertText("%")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
      .text(label: ",", tone: .dark, action: { onAction(.insertText(",")) }, enabled: true, pressedAsset: "Keyboard-orange-pressed"),
    ]
  }
}

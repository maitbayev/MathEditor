import Foundation
import MathEditor
import SwiftUI

struct KeyboardBaseLayoutView: View {
  let backgroundImageName: String
  let featureItems: [KeyboardCell]
  let middleColumns: [[KeyboardCell]]
  let utilityBackspace: KeyboardCell
  let utilityEnter: KeyboardCell
  let utilityDismiss: KeyboardCell

  var body: some View {
    GeometryReader { proxy in
      let totalWidth = proxy.size.width
      let totalHeight = proxy.size.height
      let utilityWidth = totalWidth * 0.225
      let standardColumnWidth = (totalWidth - utilityWidth) / 5
      let rowHeight = totalHeight / 4

      ZStack {
        mtMathImage(backgroundImageName)
          .resizable()
          .frame(width: totalWidth, height: totalHeight)

        HStack(spacing: 0) {
          VStack(spacing: 0) {
            ForEach(featureItems) { item in
              KeyButton(item).frame(width: standardColumnWidth, height: rowHeight)
            }
          }

          Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<4, id: \.self) { row in
              GridRow {
                ForEach(0..<4, id: \.self) { column in
                  KeyButton(middleColumns[column][row])
                    .frame(width: standardColumnWidth, height: rowHeight)
                }
              }
            }
          }

          VStack(spacing: 0) {
            KeyButton(utilityBackspace).frame(width: utilityWidth, height: rowHeight)
            KeyButton(utilityEnter).frame(width: utilityWidth, height: rowHeight * 2)
            KeyButton(utilityDismiss).frame(width: utilityWidth, height: rowHeight)
          }
        }
      }
      .frame(width: totalWidth, height: totalHeight)
    }
  }
}

func commonFeatureItems(
  keyboardState: KeyboardState,
  onAction: @escaping (KeyboardAction) -> Void
) -> [KeyboardCell] {
  [
    .text(
      label: "x", tone: .light, fontName: KeyboardFontRegistry.variableFontName,
      action: { onAction(.insertText("x")) }, enabled: keyboardState.variablesAllowed,
      pressedAsset: "Keyboard-marine-pressed"),
    .text(
      label: "y", tone: .light, fontName: KeyboardFontRegistry.variableFontName,
      action: { onAction(.insertText("y")) }, enabled: keyboardState.variablesAllowed,
      pressedAsset: "Keyboard-marine-pressed"),
    .image(
      imageName: "Fraction",
      action: { onAction(.insertText(MTSymbolFractionSlash)) },
      enabled: keyboardState.fractionsAllowed,
      accessibilityLabel: "Fraction",
      pressedAsset: "Keyboard-marine-pressed"),
    .image(
      imageName: "Exponent",
      action: { onAction(.insertText("^")) }, enabled: true, accessibilityLabel: "Exponent",
      pressedAsset: "Keyboard-marine-pressed",
      overlayAsset: keyboardState.exponentHighlighted ? "blue-button-highlighted" : nil),
  ]
}

struct KeyboardUtilityItems {
  let backspace: KeyboardCell
  let enter: KeyboardCell
  let dismiss: KeyboardCell
}

func commonUtilityItems(onAction: @escaping (KeyboardAction) -> Void) -> KeyboardUtilityItems {
  KeyboardUtilityItems(
    backspace: .image(
      imageName: "Backspace",
      action: { onAction(.backspace) }, enabled: true, accessibilityLabel: "Backspace",
      pressedAsset: "Keyboard-grey-pressed"),
    enter: .text(
      label: "Enter", tone: .light,
      action: { onAction(.insertText("\n")) }, enabled: true,
      pressedAsset: "Keyboard-grey-pressed"),
    dismiss: .image(
      imageName: "Keyboard Down",
      action: { onAction(.dismiss) }, enabled: true, accessibilityLabel: "Dismiss keyboard",
      pressedAsset: "Keyboard-grey-pressed")
  )
}

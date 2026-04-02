import Foundation
import MathEditorSwift
import SwiftUI
import iosMath

struct MainKeyboardView: View {
  let backgroundImageName: String
  let middleColumns: [[KeyboardCell]]
  let state: KeyboardState
  let onAction: (KeyboardAction) -> Void

  var body: some View {
    GeometryReader { proxy in
      let totalWidth = proxy.size.width
      let totalHeight = proxy.size.height
      let utilityWidth = totalWidth * 0.225
      let standardColumnWidth = (totalWidth - utilityWidth) / 5
      let rowHeight = totalHeight / 4

      ZStack {
        Image(backgroundImageName, bundle: .module)
          .resizable()
          .frame(width: totalWidth, height: totalHeight)

        HStack(spacing: 0) {
          VStack(spacing: 0) {
            ForEach(featuresColumn) { item in
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
            KeyButton(backspaceCell).frame(width: utilityWidth, height: rowHeight)
            KeyButton(enterCell).frame(width: utilityWidth, height: rowHeight * 2)
            KeyButton(dismissCell).frame(width: utilityWidth, height: rowHeight)
          }
        }
      }
      .frame(width: totalWidth, height: totalHeight)
    }
  }
}

extension MainKeyboardView {
  private var featuresColumn: [KeyboardCell] {
    [
      .text(
        label: "x", tone: .light, fontName: KeyboardFontRegistry.variableFontName,
        action: { onAction(.insertText("x")) }, enabled: state.variablesAllowed,
        pressedAsset: "Keyboard-marine-pressed", padding: .bottom(10)),
      .text(
        label: "y", tone: .light, fontName: KeyboardFontRegistry.variableFontName,
        action: { onAction(.insertText("y")) }, enabled: state.variablesAllowed,
        pressedAsset: "Keyboard-marine-pressed", padding: .bottom(10)),
      .image(
        imageName: "Fraction",
        action: { onAction(.insertText(MTSymbolFractionSlash)) },
        enabled: state.fractionsAllowed,
        accessibilityLabel: "Fraction",
        pressedAsset: "Keyboard-marine-pressed"),
      .image(
        imageName: "Exponent",
        action: { onAction(.insertText("^")) }, enabled: true, accessibilityLabel: "Exponent",
        pressedAsset: "Keyboard-marine-pressed",
        overlayAsset: state.exponentHighlighted ? "blue-button-highlighted" : nil),
    ]
  }
  private var backspaceCell: KeyboardCell {
    KeyboardCell.image(
      imageName: "Backspace",
      action: { onAction(.backspace) }, enabled: true, accessibilityLabel: "Backspace",
      pressedAsset: "Keyboard-grey-pressed")
  }
  private var enterCell: KeyboardCell {
    KeyboardCell.text(
      label: "Enter", tone: .light,
      fontName: "Helvetica Neue Light",
      action: { onAction(.insertText("\n")) }, enabled: true,
      pressedAsset: "Keyboard-grey-pressed")
  }
  private var dismissCell: KeyboardCell {
    KeyboardCell.image(
      imageName: "Keyboard Down",
      action: { onAction(.dismiss) }, enabled: true, accessibilityLabel: "Dismiss keyboard",
      pressedAsset: "Keyboard-grey-pressed",
      padding: .bottom(5)
    )
  }

}

import CoreText
import Foundation
import MathEditor
import SwiftUI

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
        mtMathImage("Numbers Keyboard")
          .resizable()
          .frame(width: totalWidth, height: totalHeight)

        HStack(spacing: 0) {
          VStack(spacing: 0) {
            ForEach(featureItems) { item in
              KeyButton(item).frame(width: standardColumnWidth, height: rowHeight)
            }
          }
          mainColumnsSection(columnWidth: standardColumnWidth, rowHeight: rowHeight)
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

  // 2) Main four-column block (numbers left/middle/right + operators) using Grid
  private func mainColumnsSection(columnWidth: CGFloat, rowHeight: CGFloat) -> some View {
    let columns = [numbersLeftItems, numbersMiddleItems, numbersRightItems, operatorItems]
    return Grid(horizontalSpacing: 0, verticalSpacing: 0) {
      ForEach(0..<4, id: \.self) { row in
        GridRow {
          ForEach(0..<4, id: \.self) { column in
            KeyButton(columns[column][row])
              .frame(width: columnWidth, height: rowHeight)
          }
        }
      }
    }
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
      .text(
        label: "7", tone: .dark, action: { onInsertText("7") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "4", tone: .dark, action: { onInsertText("4") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "1", tone: .dark, action: { onInsertText("1") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "0", tone: .dark, action: { onInsertText("0") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    ]
  }

  private var numbersMiddleItems: [KeyboardCell] {
    [
      .text(
        label: "8", tone: .dark, action: { onInsertText("8") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "5", tone: .dark, action: { onInsertText("5") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "2", tone: .dark, action: { onInsertText("2") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: ".", tone: .dark, action: { onInsertText(".") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
    ]
  }

  private var numbersRightItems: [KeyboardCell] {
    [
      .text(
        label: "9", tone: .dark, action: { onInsertText("9") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "6", tone: .dark, action: { onInsertText("6") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "3", tone: .dark, action: { onInsertText("3") },
        enabled: keyboardState.numbersAllowed, pressedAsset: "Keyboard-grey-pressed"),
      .text(
        label: "=", tone: keyboardState.equalsAllowed ? .dark : .disabled,
        action: { onInsertText("=") }, enabled: keyboardState.equalsAllowed,
        pressedAsset: "Keyboard-grey-pressed",
        overlayAsset: keyboardState.equalsAllowed ? nil : "num-button-disabled"),
    ]
  }

  private var operatorItems: [KeyboardCell] {
    [
      .text(
        label: "÷", tone: .dark, action: { onInsertText("÷") },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      .text(
        label: "×", tone: .dark, action: { onInsertText("×") },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      .text(
        label: "-", tone: .dark, action: { onInsertText("-") },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
      .text(
        label: "+", tone: .dark, action: { onInsertText("+") },
        enabled: keyboardState.operatorsAllowed, pressedAsset: "Keyboard-orange-pressed"),
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
}

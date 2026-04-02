import Foundation
import SwiftUI

struct LettersKeyboardView: View {
  let state: KeyboardState
  let isLowercase: Bool
  let onShift: () -> Void
  let onAction: (KeyboardAction) -> Void

  private var topRow: [String] {
    makeLetterRow(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"])
  }

  private var middleRow: [String] {
    makeLetterRow(["a", "s", "d", "f", "g", "h", "j", "k", "l"])
  }

  private var bottomRow: [String] {
    makeLetterRow(["z", "x", "c", "v", "b", "n", "m"])
  }

  private var greekRow: [GreekKey] {
    if isLowercase {
      return [
        GreekKey(label: "α", accessibilityLabel: "alpha"),
        GreekKey(label: "Δ", accessibilityLabel: "capital delta"),
        GreekKey(label: "σ", accessibilityLabel: "sigma"),
        GreekKey(label: "μ", accessibilityLabel: "mu"),
        GreekKey(label: "λ", accessibilityLabel: "lambda"),
      ]
    }

    return [
      GreekKey(label: "ρ", accessibilityLabel: "rho"),
      GreekKey(label: "ω", accessibilityLabel: "omega"),
      GreekKey(label: "Φ", accessibilityLabel: "capital phi"),
      GreekKey(label: "ν", accessibilityLabel: "nu"),
      GreekKey(label: "β", accessibilityLabel: "beta"),
    ]
  }

  var body: some View {
    GeometryReader { proxy in
      let unitWidth = proxy.size.width / 10
      let rowHeight = proxy.size.height / 4

      ZStack {
        Image("Letters Keyboard", bundle: .module)
          .resizable()
          .frame(width: proxy.size.width, height: proxy.size.height)

        VStack(spacing: 0) {
          letterRow(topRow, horizontalInset: 0, unitWidth: unitWidth, rowHeight: rowHeight)
          letterRow(
            middleRow, horizontalInset: unitWidth / 2, unitWidth: unitWidth, rowHeight: rowHeight)
          bottomLetterRow(unitWidth: unitWidth, rowHeight: rowHeight)
          greekRowView(unitWidth: unitWidth, rowHeight: rowHeight)
        }
      }
    }
  }

  @ViewBuilder
  private func letterRow(
    _ letters: [String],
    horizontalInset: CGFloat,
    unitWidth: CGFloat,
    rowHeight: CGFloat
  ) -> some View {
    HStack(spacing: 0) {
      Color.clear.frame(width: horizontalInset)
      ForEach(letters, id: \.self) { letter in
        letterCell(letter)
          .frame(width: unitWidth, height: rowHeight)
      }
      Color.clear.frame(width: horizontalInset)
    }
  }

  @ViewBuilder
  private func bottomLetterRow(unitWidth: CGFloat, rowHeight: CGFloat) -> some View {
    HStack(spacing: 0) {
      KeyButton(shiftCell)
        .frame(width: unitWidth * 1.5, height: rowHeight)

      ForEach(bottomRow, id: \.self) { letter in
        letterCell(letter)
          .frame(width: unitWidth, height: rowHeight)
      }

      KeyButton(backspaceCell)
        .frame(width: unitWidth * 1.5, height: rowHeight)
    }
  }

  @ViewBuilder
  private func greekRowView(unitWidth: CGFloat, rowHeight: CGFloat) -> some View {
    HStack(spacing: 0) {
      KeyButton(dismissCell)
        .frame(width: unitWidth * 2.5, height: rowHeight)

      ForEach(greekRow) { key in
        KeyButton(greekCell(key))
          .frame(width: unitWidth, height: rowHeight)
      }

      KeyButton(enterCell)
        .frame(width: unitWidth * 2.5, height: rowHeight)
    }
  }

  private func makeLetterRow(_ letters: [String]) -> [String] {
    if isLowercase {
      return letters
    }
    return letters.map { $0.uppercased() }
  }

  private func letterCell(_ label: String) -> KeyButton {
    KeyButton(
      .text(
        label: label,
        tone: .dark,
        action: { onAction(.insertText(label)) },
        enabled: true,
        pressedAsset: "Keyboard-azure-pressed"
      )
    )
  }

  private func greekCell(_ key: GreekKey) -> KeyboardCell {
    .text(
      label: key.label,
      tone: .dark,
      fontName: "CourierNewPS-ItalicMT",
      action: { onAction(.insertText(key.label)) },
      enabled: true,
      accessibilityLabel: key.accessibilityLabel,
      pressedAsset: "Keyboard-azure-pressed"
    )
  }

  private var shiftCell: KeyboardCell {
    .image(
      imageName: "Shift",
      action: onShift,
      enabled: true,
      accessibilityLabel: "Shift",
      pressedAsset: "Keyboard-grey-pressed"
    )
  }

  private var backspaceCell: KeyboardCell {
    .image(
      imageName: "Backspace Small",
      action: { onAction(.backspace) },
      enabled: true,
      accessibilityLabel: "Backspace",
      pressedAsset: "Keyboard-grey-pressed"
    )
  }

  private var dismissCell: KeyboardCell {
    .image(
      imageName: "Keyboard Down",
      action: { onAction(.dismiss) },
      enabled: true,
      accessibilityLabel: "Dismiss keyboard",
      pressedAsset: "Keyboard-grey-pressed"
    )
  }

  private var enterCell: KeyboardCell {
    .text(
      label: "Enter",
      tone: .light,
      fontName: "HelveticaNeue-Light",
      action: { onAction(.insertText("\n")) },
      enabled: true,
      pressedAsset: "Keyboard-grey-pressed"
    )
  }
}

private struct GreekKey: Identifiable {
  let id = UUID()
  let label: String
  let accessibilityLabel: String
}

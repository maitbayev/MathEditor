//
//  KeyButton.swift
//  MathKeyboardSwift
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

import SwiftUI

struct KeyButton: View {
  var cell: KeyboardCell

  init(_ cell: KeyboardCell) {
    self.cell = cell
  }

  var body: some View {
    Button(action: cell.action) {
      ZStack {
        Rectangle().fill(Color.white.opacity(0.001))
        if let overlayAsset = cell.overlayAsset {
          Image(overlayAsset, bundle: .module)
            .resizable()
        }
        switch cell.content {
        case .text(let text):
          Text(text.value)
            .font(.custom(text.fontName, size: text.fontSize))
            .foregroundColor(textColor(for: text.tone))
            .padding(cell.padding)
        case .image(let image):
          Image(image.name, bundle: .module)
            .renderingMode(.original)
            .scaledToFill()
            .padding(cell.padding)
        }
      }
    }
    .buttonStyle(
      KeyboardPressStyle(pressedAsset: cell.pressedAsset)
    )
    .disabled(!cell.enabled)
    .opacity(cell.enabled ? 1 : 0.75)
    .accessibilityLabel(cell.accessibilityLabel)
  }
}

private func textColor(for tone: KeyboardCell.TextTone) -> Color {
  switch tone {
  case .light: .white
  case .dark: .black
  case .disabled: Color(white: 0.67)
  }
}

private struct KeyboardPressStyle: ButtonStyle {
  let pressedAsset: String?

  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      if configuration.isPressed {
        if let pressedAsset {
          Image(pressedAsset, bundle: .module)
            .resizable()
            .opacity(1.0)
        } else {
          Color.clear
        }
      }
      configuration.label
    }
  }
}

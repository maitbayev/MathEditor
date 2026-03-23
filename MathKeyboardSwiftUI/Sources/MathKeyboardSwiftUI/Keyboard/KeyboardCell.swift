//
//  KeyboardCell.swift
//  MathKeyboardSwiftUI
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

import Foundation

struct KeyboardCell: Identifiable {
  enum Content {
    case text(TextContent)
    case image(ImageContent)
  }

  struct TextContent {
    let value: String
    let fontName: String
    let fontSize: Double
    let tone: TextTone
  }

  struct ImageContent {
    let name: String
    let padding: Double
  }

  enum TextTone {
    case light
    case dark
    case disabled
  }

  let id = UUID()
  let content: Content
  let action: () -> Void
  let enabled: Bool
  let accessibilityLabel: String
  let pressedAsset: String?
  let overlayAsset: String?

  static func text(
    label: String,
    tone: TextTone,
    fontName: String = "HelveticaNeue-Thin",
    fontSize: CGFloat = 20,
    action: @escaping () -> Void,
    enabled: Bool,
    accessibilityLabel: String? = nil,
    pressedAsset: String? = nil,
    overlayAsset: String? = nil
  ) -> KeyboardCell {
    KeyboardCell(
      content: .text(
        TextContent(
          value: label,
          fontName: fontName,
          fontSize: fontSize,
          tone: tone
        )
      ),
      action: action,
      enabled: enabled,
      accessibilityLabel: accessibilityLabel ?? label,
      pressedAsset: pressedAsset,
      overlayAsset: overlayAsset
    )
  }

  static func image(
    imageName: String,
    action: @escaping () -> Void,
    enabled: Bool,
    accessibilityLabel: String,
    pressedAsset: String? = nil,
    overlayAsset: String? = nil
  ) -> KeyboardCell {
    KeyboardCell(
      content: .image(ImageContent(name: imageName, padding: 8)),
      action: action,
      enabled: enabled,
      accessibilityLabel: accessibilityLabel,
      pressedAsset: pressedAsset,
      overlayAsset: overlayAsset
    )
  }
}

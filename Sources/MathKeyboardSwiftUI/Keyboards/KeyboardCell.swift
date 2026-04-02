//
//  KeyboardCell.swift
//  MathKeyboardSwiftUI
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

import Foundation
import SwiftUI

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
  var padding: EdgeInsets

  static func text(
    label: String,
    tone: TextTone,
    fontName: String = "HelveticaNeue-Thin",
    fontSize: CGFloat = 20,
    action: @escaping () -> Void,
    enabled: Bool,
    accessibilityLabel: String? = nil,
    pressedAsset: String? = nil,
    overlayAsset: String? = nil,
    padding: EdgeInsets = .zero,
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
      overlayAsset: overlayAsset,
      padding: padding
    )
  }

  static func image(
    imageName: String,
    action: @escaping () -> Void,
    enabled: Bool,
    accessibilityLabel: String,
    pressedAsset: String? = nil,
    overlayAsset: String? = nil,
    padding: EdgeInsets = .zero,
  ) -> KeyboardCell {
    KeyboardCell(
      content: .image(ImageContent(name: imageName)),
      action: action,
      enabled: enabled,
      accessibilityLabel: accessibilityLabel,
      pressedAsset: pressedAsset,
      overlayAsset: overlayAsset,
      padding: padding
    )
  }
}

extension EdgeInsets {
  static var zero: EdgeInsets {
    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
  }

  static func bottom(_ length: CGFloat) -> EdgeInsets {
    EdgeInsets(top: 0, leading: 0, bottom: length, trailing: 0)
  }

  static func top(_ length: CGFloat) -> EdgeInsets {
    EdgeInsets(top: length, leading: 0, bottom: 0, trailing: 0)
  }
}

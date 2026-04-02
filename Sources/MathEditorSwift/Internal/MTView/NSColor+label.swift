//
//  NSColor+labelColor.swift
//  MathEditorSwift
//
//  Created by Madiyar Aitbayev on 26/03/2026.
//

#if canImport(AppKit)
  import AppKit

  extension NSColor {
    static var label: NSColor {
      NSColor.labelColor
    }
  }

#endif  // canImport(AppKit)

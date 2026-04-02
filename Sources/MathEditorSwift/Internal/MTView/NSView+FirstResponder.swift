//
//  MTView+FirstResponder.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

#if os(macOS)

  import AppKit

  extension NSView {
    @objc var isFirstResponder: Bool {
      window?.firstResponder == self
    }
  }

#endif

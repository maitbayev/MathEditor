//
//  NSView+Layout.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

#if canImport(AppKit)
  import AppKit

  extension NSView {
    func setNeedsLayout() {
      self.needsDisplay = true
    }

    func setNeedsDisplay() {
      self.needsDisplay = true
    }

    func layoutIfNeeded() {
      layoutSubtreeIfNeeded()
    }

    func bringSubviewToFront(_ child: NSView) {
      guard child.superview == self else { return }
      child.removeFromSuperview()
      addSubview(child)
    }
  }
#endif

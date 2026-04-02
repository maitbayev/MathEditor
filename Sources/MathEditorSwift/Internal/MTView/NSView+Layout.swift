//
//  NSView+Layout.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

#if canImport(AppKit)
  import AppKit

  extension NSView {
    @objc(setNeedsLayout)
    public func setNeedsLayout() {
      self.needsDisplay = true
    }

    @objc(setNeedsDisplay)
    public func setNeedsDisplay() {
      self.needsDisplay = true
    }

    @objc(layoutIfNeeded)
    public func layoutIfNeeded() {
      layoutSubtreeIfNeeded()
    }

    @objc(bringSubviewToFront:)
    public func bringSubviewToFront(_ child: NSView) {
      guard child.superview == self else { return }
      child.removeFromSuperview()
      addSubview(child)
    }
  }
#endif

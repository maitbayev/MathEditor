//
//  MTView+HitTest.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

#if canImport(AppKit)
  import AppKit
  extension NSView {
    @objc func hitTestOutsideBounds(_ point: NSPoint) -> NSView? {
      hitTestOutsideBounds(point, ignoringSubviews: [])
    }

    @objc func hitTestOutsideBounds(_ point: NSPoint, ignoringSubviews: [NSView]) -> NSView? {
      if isHidden {
        return nil
      }

      let localPoint = convert(point, from: superview)
      for child in subviews.reversed() {
        if ignoringSubviews.contains(child) {
          continue
        }
        if let hitView = child.hitTest(localPoint) {
          return hitView
        }
      }

      if bounds.contains(localPoint) {
        return self
      }

      return nil
    }
  }
#endif

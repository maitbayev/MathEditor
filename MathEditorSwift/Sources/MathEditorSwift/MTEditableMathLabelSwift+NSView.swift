import Foundation

#if canImport(AppKit)
  import AppKit

  extension MTEditableMathLabelSwift {
    public override func layout() {
      super.layout()
      doLayout()
    }

    public override var isFlipped: Bool { true }

    public override func hitTest(_ point: NSPoint) -> NSView? {
      hitTestOutsideBounds(point, ignoringSubviews: [label])
    }
  }
#endif

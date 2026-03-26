import Foundation

#if canImport(UIKit)
  import UIKit
#endif
#if canImport(AppKit)
  import AppKit
#endif

extension MTEditableMathLabelSwift {
  public override func becomeFirstResponder() -> Bool {
    let didBecome = super.becomeFirstResponder()
    if didBecome {
      doBecomeFirstResponder()
    }
    return didBecome
  }

  public override func resignFirstResponder() -> Bool {
    guard isFirstResponder else { return true }
    let didResign = super.resignFirstResponder()
    doResignFirstResponder()
    return didResign
  }
}

#if canImport(UIKit)
  extension MTEditableMathLabelSwift {
    public override var inputView: UIView? {
      keyboard as? UIView
    }

    public override var canBecomeFirstResponder: Bool { true }
  }
#endif

#if canImport(AppKit)
  extension MTEditableMathLabelSwift {
    public override var acceptsFirstResponder: Bool { true }

    public override func keyDown(with event: NSEvent) {
      // interpretKeyEvents feeds the event into the input system,
      // which calls insertText: or deleteBackward: as appropriate.
      interpretKeyEvents([event])
    }

    public override func deleteBackward(_ sender: Any?) {
      deleteBackward()
    }
  }
#endif

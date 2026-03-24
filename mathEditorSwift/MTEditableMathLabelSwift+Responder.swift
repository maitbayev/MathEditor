import Foundation

#if canImport(UIKit)
  import UIKit

  extension MTEditableMathLabelSwift: UIKeyInput {
    public override var inputView: UIView? {
      keyboard as? UIView
    }

    public override var canBecomeFirstResponder: Bool { true }

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
#elseif canImport(AppKit)
  import AppKit

  extension MTEditableMathLabelSwift {
    public override var acceptsFirstResponder: Bool { true }

    public override func becomeFirstResponder() -> Bool {
      let didBecome = super.becomeFirstResponder()
      if didBecome {
        doBecomeFirstResponder()
      }
      return didBecome
    }

    public override func resignFirstResponder() -> Bool {
      guard window?.firstResponder === self else { return true }
      let didResign = super.resignFirstResponder()
      doResignFirstResponder()
      return didResign
    }

    public override func keyDown(with event: NSEvent) {
      interpretKeyEvents([event])
    }

    public override func deleteBackward(_ sender: Any?) {
      deleteBackward()
    }
  }
#endif

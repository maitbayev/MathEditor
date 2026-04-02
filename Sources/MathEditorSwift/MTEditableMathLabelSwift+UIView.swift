import Foundation

#if canImport(UIKit)
  import UIKit

  extension MTEditableMathLabelSwift {
    public override func layoutSubviews() {
      super.layoutSubviews()
      doLayout()
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
      if super.point(inside: point, with: event) {
        return true
      }
      return caretView.point(inside: convert(point, to: caretView), with: event)
    }
  }
#endif

import Foundation

#if os(iOS)
  import UIKit
  typealias MTView = UIView
  typealias MTViewEdgeInsets = UIEdgeInsets
#elseif os(macOS)
  import AppKit
  typealias MTView = NSView
  typealias MTViewEdgeInsets = NSEdgeInsets
#endif

extension MTView {
  func pinToSuperview() {
    pinToSuperview(insets: .zero)
  }

  func pinToSuperview(insets: MTViewEdgeInsets) {
    guard let superview else { return }

    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
      bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
    ])
  }
}

extension MTViewEdgeInsets {
#if os(macOS)
  static var zero: Self {
      NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
#endif
}

import Foundation

#if os(iOS)
  import UIKit
  typealias MTView = UIView
#elseif os(macOS)
  import AppKit
  typealias MTView = NSView
#endif

extension MTView {
  func pinToSuperview() {
    pinToSuperview(top: 0, leading: 0, bottom: 0, trailing: 0)
  }

  func pinToSuperview(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
    guard let superview else { return }

    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.topAnchor, constant: top),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -trailing),
      bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom),
    ])
  }
}

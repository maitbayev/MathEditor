#if canImport(AppKit)
import AppKit
public typealias MXView = NSView
#elseif canImport(UIKit)
import UIKit
public typealias MXView = UIView
#endif

public extension MXView {
  @objc(pinToSuperview)
  func pinToSuperview() {
    pinToSuperview(withTop: 0, leading: 0, bottom: 0, trailing: 0)
  }

  @objc(pinToSuperviewWithTop:leading:bottom:trailing:)
  func pinToSuperview(withTop top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
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

#if canImport(AppKit)
public extension NSView {
  @objc(setNeedsLayout)
  func setNeedsLayout() {
    setNeedsLayout(true)
  }

  @objc(setNeedsDisplay)
  func setNeedsDisplay() {
    setNeedsDisplay(true)
  }

  @objc(layoutIfNeeded)
  func layoutIfNeeded() {
    layoutSubtreeIfNeeded()
  }

  @objc(bringSubviewToFront:)
  func bringSubviewToFront(_ child: NSView) {
    guard child.superview == self else { return }
    child.removeFromSuperview()
    addSubview(child)
  }

  @objc(isFirstResponder)
  var isFirstResponder: Bool {
    window?.firstResponder == self
  }

  @objc(hitTestOutsideBounds:)
  func hitTestOutsideBounds(_ point: NSPoint) -> NSView? {
    hitTestOutsideBounds(point, ignoringSubviews: [])
  }

  @objc(hitTestOutsideBounds:ignoringSubviews:)
  func hitTestOutsideBounds(_ point: NSPoint, ignoringSubviews: [NSView]) -> NSView? {
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

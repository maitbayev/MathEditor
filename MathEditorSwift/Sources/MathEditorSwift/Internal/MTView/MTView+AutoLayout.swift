//
//  MTView+AutoLayout.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

import Foundation

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

extension MTView {
  @objc public func pinToSuperview() {
    pinToSuperview(withTop: 0, leading: 0, bottom: 0, trailing: 0)
  }

  @objc public func pinToSuperview(
    withTop top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat
  ) {
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

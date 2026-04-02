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
  public func pinToSuperview(
    top: Double = 0, leading: Double = 0, bottom: Double = 0, trailing: Double = 0
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

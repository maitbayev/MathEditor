//
//  MTView.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

#if canImport(AppKit)
  import AppKit
  public typealias MTView = NSView
#elseif canImport(UIKit)
  import UIKit
  public typealias MTView = UIView
#endif

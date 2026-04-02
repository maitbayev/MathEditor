//
//  MTView.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

import Foundation

#if canImport(UIKit)
  import UIKit
  public typealias MTView = UIView
  public typealias MTColor = UIColor
  public typealias MTBezierPath = UIBezierPath
  public typealias MTImage = UIImage
  public typealias MTImageView = UIImageView
  public typealias MTEdgeInsets = UIEdgeInsets
#elseif canImport(AppKit)
  import AppKit
  public typealias MTView = NSView
  public typealias MTColor = NSColor
  public typealias MTBezierPath = NSBezierPath
  public typealias MTImage = NSImage
  public typealias MTImageView = NSImageView
  public typealias MTEdgeInsets = NSEdgeInsets
#endif

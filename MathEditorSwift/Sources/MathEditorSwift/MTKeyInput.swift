//
//  MTKeyInput.swift
//  MathEditorSwift
//
//  Created by Madiyar Aitbayev on 26/03/2026.
//


#if canImport(UIKit)
import UIKit
public typealias MTKeyInput = UIKeyInput
#else
public protocol MTKeyInput {
  var hasText: Bool { get }
  func insertText(_ text: String)
  func deleteBackward()
}
#endif


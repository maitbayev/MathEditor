//
//  MTTextInputHandler.swift
//  MathEditorSwift
//
//  Created by Madiyar Aitbayev on 26/03/2026.
//

#if canImport(UIKit)

  import UIKit

  struct DummyTextInputHandler {
    var selectedTextRange: UITextRange?
    var markedTextRange: UITextRange?
    var markedTextStyle: [NSAttributedString.Key: Any]?
    var beginningOfDocument = UITextPosition()
    var endOfDocument = UITextPosition()
    var inputDelegate: (any UITextInputDelegate)?
    var tokenizer: UITextInputTokenizer = UITextInputStringTokenizer()
  }

#else  // canImport(UIKit)

  struct DummyTextInputHandler {
  }

#endif  // canImport(UIKit)

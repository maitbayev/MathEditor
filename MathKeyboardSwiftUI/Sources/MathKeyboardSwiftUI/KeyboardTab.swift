//
//  KeyboardTab.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

enum KeyboardTab: CaseIterable, Hashable, Equatable, Identifiable {
  case numbers
  case legacyNumbers
  case operations
  case functions
  case letters

  var id: Self { self }
}

extension KeyboardTab {
  var imageNames: (normal: String, selected: String)? {
    switch self {
    case .numbers: return ("Numbers Symbol wbg", "Number Symbol")
    case .legacyNumbers: return nil
    case .operations: return ("Operations Symbol wbg", "Operations Symbol")
    case .functions: return ("Functions Symbol wbg", "Functions Symbol")
    case .letters: return ("Letter Symbol wbg", "Letter Symbol")
    }
  }

  var nibName: String {
    switch self {
    case .numbers: return "MTKeyboard"
    case .legacyNumbers: return "MTKeyboard"
    case .operations: return "MTKeyboardTab2"
    case .functions: return "MTKeyboardTab3"
    case .letters: return "MTKeyboardTab4"
    }
  }

  var title: String? {
    switch self {
    case .legacyNumbers: return "Old"
    default: return nil
    }
  }
}

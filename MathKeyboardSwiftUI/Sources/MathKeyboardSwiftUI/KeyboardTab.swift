//
//  KeyboardTab.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

enum KeyboardTab: CaseIterable, Hashable, Equatable, Identifiable {
  case numbers
  case operations
  case functions
  case letters

  var id: Self { self }
}

extension KeyboardTab {
  var imageNames: (normal: String, selected: String) {
    switch self {
    case .numbers: ("Numbers Symbol wbg", "Number Symbol")
    case .operations: ("Operations Symbol wbg", "Operations Symbol")
    case .functions: ("Functions Symbol wbg", "Functions Symbol")
    case .letters: ("Letter Symbol wbg", "Letter Symbol")
    }
  }
}

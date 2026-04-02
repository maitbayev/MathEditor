//
//  KeyboardState.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

struct KeyboardState: Equatable {
  var currentTab: KeyboardTab = .numbers
  var isLowercase = true
  var equalsAllowed = true
  var fractionsAllowed = true
  var variablesAllowed = true
  var numbersAllowed = true
  var operatorsAllowed = true
  var exponentHighlighted = false
  var squareRootHighlighted = false
  var radicalHighlighted = false
}

//
//  NumbersKeyboardUIView.swift
//  MathKeyboardSwiftUI
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

#if os(iOS)

  import MathKeyboard
  import UIKit

  protocol KeyboardConfigurable: AnyObject {
    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?)
    func applyKeyboardState(_ state: KeyboardState)
  }

  extension MTKeyboard: KeyboardConfigurable {
    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?) {
      self.textView = textView
    }

    func applyKeyboardState(_ state: KeyboardState) {
      setNumbersState(state.numbersAllowed)
      setOperatorState(state.operatorsAllowed)
      setVariablesState(state.variablesAllowed)
      setFractionState(state.fractionsAllowed)
      setEqualsState(state.equalsAllowed)
      setExponentState(state.exponentHighlighted)
      setSquareRootState(state.squareRootHighlighted)
      setRadicalState(state.radicalHighlighted)
    }
  }

#endif  // os(iOS)

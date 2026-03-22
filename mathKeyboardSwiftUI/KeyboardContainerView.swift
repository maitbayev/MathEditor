//
//  KeyboardContainerView.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

#if os(iOS)

import MathEditor
import MathKeyboard
import SwiftUI
import UIKit

struct KeyboardContainerView: UIViewRepresentable {
  let state: KeyboardState
  weak var textInput: (any UIView & UIKeyInput)?

  func makeUIView(context: Context) -> KeyboardContainerUIView {
    let view = KeyboardContainerUIView()
    view.sync(
      state: state,
      editingTarget: textInput
    )
    return view
  }

  func updateUIView(_ uiView: KeyboardContainerUIView, context: Context) {
    uiView.sync(
      state: state,
      editingTarget: textInput
    )
  }
}

final class KeyboardContainerUIView: UIView {
  private weak var currentKeyboard: UIView?
  private lazy var keyboards: [KeyboardTab: MTKeyboard] = Dictionary(
    uniqueKeysWithValues: KeyboardTab.allCases.map { tab in
      (tab, makeKeyboard(named: tab.nibName))
    }
  )

  fileprivate func sync(state: KeyboardState, editingTarget: (any UIView & UIKeyInput)?) {
    for keyboard in keyboards.values {
      keyboard.textView = editingTarget
      keyboard.setEqualsState(state.equalsAllowed)
      keyboard.setFractionState(state.fractionsAllowed)
      keyboard.setVariablesState(state.variablesAllowed)
      keyboard.setNumbersState(state.numbersAllowed)
      keyboard.setOperatorState(state.operatorsAllowed)
      keyboard.setExponentState(state.exponentHighlighted)
      keyboard.setSquareRootState(state.squareRootHighlighted)
      keyboard.setRadicalState(state.radicalHighlighted)
    }

    display(keyboard: keyboards[state.currentTab]!)
  }

  fileprivate func display(keyboard: UIView) {
    guard currentKeyboard !== keyboard else { return }

    currentKeyboard?.removeFromSuperview()
    currentKeyboard = keyboard
    addSubview(keyboard)

    NSLayoutConstraint.activate([
      keyboard.topAnchor.constraint(equalTo: topAnchor),
      keyboard.leadingAnchor.constraint(equalTo: leadingAnchor),
      keyboard.trailingAnchor.constraint(equalTo: trailingAnchor),
      keyboard.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func makeKeyboard(named nibName: String) -> MTKeyboard {
    let bundle = MTMathKeyboardRootView.getMathKeyboardResourcesBundle()
    let keyboard = UINib(nibName: nibName, bundle: bundle)
      .instantiate(withOwner: nil, options: nil)
      .compactMap { $0 as? MTKeyboard }
      .first!
    keyboard.translatesAutoresizingMaskIntoConstraints = false
    return keyboard
  }
}

#endif // os(iOS)

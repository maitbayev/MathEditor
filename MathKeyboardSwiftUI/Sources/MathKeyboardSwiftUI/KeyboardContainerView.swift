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
    private lazy var keyboards: [KeyboardTab: (UIView & KeyboardConfigurable)] = [
      .numbers: makeNumbersKeyboard(),
      .legacyNumbers: makeKeyboard(named: KeyboardTab.legacyNumbers.nibName),
      .operations: makeOperationsKeyboard(),
      .functions: makeKeyboard(named: KeyboardTab.functions.nibName),
      .letters: makeKeyboard(named: KeyboardTab.letters.nibName),
    ]

    fileprivate func sync(state: KeyboardState, editingTarget: (any UIView & UIKeyInput)?) {
      for keyboard in keyboards.values {
        keyboard.setEditingTarget(editingTarget)
        keyboard.applyKeyboardState(state)
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

    private func makeSwiftUIKeyboard(
      @ViewBuilder content: @escaping (KeyboardState, @escaping (KeyboardAction) -> Void) -> some View
    ) -> UIView & KeyboardConfigurable {
      let keyboard = SwiftUIKeyboardHostView { state, onAction in
        AnyView(content(state, onAction))
      }
      keyboard.translatesAutoresizingMaskIntoConstraints = false
      return keyboard
    }

    private func makeNumbersKeyboard() -> UIView & KeyboardConfigurable {
      makeSwiftUIKeyboard { state, onAction in
        NumbersKeyboardView(keyboardState: state, onAction: onAction)
      }
    }

    private func makeOperationsKeyboard() -> UIView & KeyboardConfigurable {
      makeSwiftUIKeyboard { state, onAction in
        OperationsKeyboardView(keyboardState: state, onAction: onAction)
      }
    }

    private func makeKeyboard(named nibName: String) -> UIView & KeyboardConfigurable {
      let bundle = MTMathKeyboardRootView.getMathKeyboardResourcesBundle()
      let keyboard = UINib(nibName: nibName, bundle: bundle)
        .instantiate(withOwner: nil, options: nil)
        .compactMap { $0 as? MTKeyboard }
        .first!
      keyboard.translatesAutoresizingMaskIntoConstraints = false
      return keyboard
    }
  }

#endif  // os(iOS)

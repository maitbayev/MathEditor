//
//  NumbersKeyboardUIView.swift
//  MathKeyboardSwiftUI
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

#if os(iOS)

  import UIKit
  import MathKeyboard
  import SwiftUI

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

  final class NumbersKeyboardHostView: UIView, KeyboardConfigurable, UIInputViewAudioFeedback {
    private var keyboardState = KeyboardState()
    private weak var editingTarget: (any UIView & UIKeyInput)?
    private lazy var hostingController = UIHostingController(rootView: makeRootView())

    override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }

    required init?(coder: NSCoder) {
      super.init(coder: coder)
      commonInit()
    }

    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?) {
      editingTarget = textView
    }

    func applyKeyboardState(_ state: KeyboardState) {
      updateState { $0 = state }
    }

    var enableInputClicksWhenVisible: Bool { true }

    private func commonInit() {
      backgroundColor = .white

      let hostedView = hostingController.view!
      if #available(iOS 16.4, *) {
        hostingController.safeAreaRegions = []
      }
      hostedView.backgroundColor = .clear
      hostedView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(hostedView)

      NSLayoutConstraint.activate([
        hostedView.topAnchor.constraint(equalTo: topAnchor),
        hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
        hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
        hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
    }

    private func makeRootView() -> NumbersKeyboardView {
      NumbersKeyboardView(
        keyboardState: keyboardState,
        onInsertText: { [weak self] text in self?.insert(text) },
        onBackspace: { [weak self] in self?.backspace() },
        onDismiss: { [weak self] in self?.dismissKeyboard() }
      )
    }

    private func insert(_ text: String) {
      playClickForCustomKeyTap()
      editingTarget?.insertText(text)
    }

    private func backspace() {
      playClickForCustomKeyTap()
      editingTarget?.deleteBackward()
    }

    private func dismissKeyboard() {
      playClickForCustomKeyTap()
      editingTarget?.resignFirstResponder()
    }

    private func playClickForCustomKeyTap() {
      UIDevice.current.playInputClick()
    }

    private func updateState(_ update: @escaping (inout KeyboardState) -> Void) {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        let previousState = self.keyboardState
        update(&self.keyboardState)
        guard self.keyboardState != previousState else { return }
        self.hostingController.rootView = self.makeRootView()
      }
    }
  }

#endif  // os(iOS)

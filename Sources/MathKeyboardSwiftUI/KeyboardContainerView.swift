//
//  KeyboardContainerView.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

import SwiftUI

struct KeyboardContainerView: View {
  let state: KeyboardState
  let onAction: (KeyboardAction) -> Void

  var body: some View {
    keyboardView(for: state.currentTab)
  }

  @ViewBuilder
  private func keyboardView(for tab: KeyboardTab) -> some View {
    switch tab {
    case .numbers:
      NumbersKeyboardView(state: state, onAction: onAction)
    case .operations:
      OperationsKeyboardView(state: state, onAction: onAction)
    case .functions:
      FunctionsKeyboardView(state: state, onAction: onAction)
    case .letters:
      LettersKeyboardView(
        state: state,
        isLowercase: state.isLowercase,
        onShift: { onAction(.toggleShift) },
        onAction: onAction
      )
    }
  }
}

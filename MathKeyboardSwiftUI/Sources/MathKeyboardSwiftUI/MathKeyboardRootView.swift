//
//  MathKeyboardRootView.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

import SwiftUI

public struct MathKeyboardRootView: View {
  let state: KeyboardState
  let onTabSelected: (KeyboardTab) -> Void
  let onAction: (KeyboardAction) -> Void

  public var body: some View {
    GeometryReader { proxy in
      let totalHeight = proxy.size.height
      let tabHeight = totalHeight / 5.0
      let keyboardHeight = totalHeight - tabHeight

      VStack(spacing: 0) {
        HStack(spacing: 0) {
          ForEach(KeyboardTab.allCases) { tab in
            Button {
              onTabSelected(tab)
            } label: {
              Image(tab.imageName(for: state), bundle: .module)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .background(Color(white: 0.768627451))
          }
        }
        .frame(height: tabHeight)

        KeyboardContainerView(
          state: state,
          onAction: onAction
        )
        .frame(height: keyboardHeight)
      }
      .background(Color.white)
      .ignoresSafeArea()
    }
  }
}

extension KeyboardTab {
  fileprivate func imageName(for state: KeyboardState) -> String {
    state.currentTab == self ? imageNames.selected : imageNames.normal
  }
}

//
//  MathKeyboardRootView.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 22/03/2026.
//

import SwiftUI

#if os(iOS)
  import MathKeyboard

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
                Image(uiImage: tabImage(for: tab))
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

    private func tabImage(for tab: KeyboardTab) -> UIImage {
      let names = tab.imageNames
      let name = state.currentTab == tab ? names.selected : names.normal
      return UIImage(
        named: name,
        in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
        compatibleWith: nil
      ) ?? UIImage()
    }
  }

#endif  // os(iOS)

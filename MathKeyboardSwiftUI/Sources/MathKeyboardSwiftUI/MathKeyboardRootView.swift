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
    weak var textInput: (any UIView & UIKeyInput)?
    let onTabSelected: (KeyboardTab) -> Void

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
                if let image = tabImage(for: tab) {
                  Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                } else {
                  Text(tab.title ?? "")
                    .font(.system(size: 14, weight: state.currentTab == tab ? .semibold : .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
              }
              .buttonStyle(.plain)
              .background(Color(white: 0.768627451))
            }
          }
          .frame(height: tabHeight)

          KeyboardContainerView(
            state: state,
            textInput: textInput
          )
          .frame(height: keyboardHeight)
        }
        .background(Color.white)
        .ignoresSafeArea()
      }
    }

    private func tabImage(for tab: KeyboardTab) -> UIImage? {
      guard let names = tab.imageNames else {
        return nil
      }
      let name = state.currentTab == tab ? names.selected : names.normal
      return UIImage(
        named: name,
        in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
        compatibleWith: nil
      )
    }
  }

#endif  // os(iOS)

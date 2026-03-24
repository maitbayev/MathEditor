//
//  MTMathKeyboard.swift
//  MathKeyboardSwiftUI
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

import SwiftUI

#if os(iOS)

  import MathKeyboard

  func mtMathImage(_ name: String) -> Image {
    if let image = UIImage(
      named: name,
      in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
      compatibleWith: nil
    ) {
      return Image(uiImage: image)
    }
    return Image(systemName: "questionmark.square.dashed")
  }

#else

  func mtMathImage(_ name: String) -> Image {
    Image(systemName: "questionmark.square.dashed")
  }

#endif

enum KeyboardFontRegistry {
  static let variableFontName: String = {
    #if os(iOS)
      guard let bundle = MTMathKeyboardRootView.getMathKeyboardResourcesBundle() else {
        return "HelveticaNeue"
      }
      guard
        let fontURL = bundle.url(forResource: "lmroman10-bolditalic", withExtension: "otf"),
        let provider = CGDataProvider(url: fontURL as CFURL),
        let font = CGFont(provider)
      else {
        return "HelveticaNeue"
      }

      let postScriptName = font.postScriptName as String? ?? "HelveticaNeue"
      var error: Unmanaged<CFError>?
      CTFontManagerRegisterGraphicsFont(font, &error)
      return postScriptName
    #else
      return "HelveticaNeue"
    #endif
  }()
}

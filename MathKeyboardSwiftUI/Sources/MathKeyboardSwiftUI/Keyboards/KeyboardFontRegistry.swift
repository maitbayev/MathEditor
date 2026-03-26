//
//  MTMathKeyboard.swift
//  MathKeyboardSwiftUI
//
//  Created by Madiyar Aitbayev on 23/03/2026.
//

import SwiftUI

enum KeyboardFontRegistry {
  static let variableFontName: String = {
    guard
      let fontURL = Bundle.module.url(forResource: "lmroman10-bolditalic", withExtension: "otf"),
      let provider = CGDataProvider(url: fontURL as CFURL),
      let font = CGFont(provider)
    else {
      return "HelveticaNeue"
    }

    let postScriptName = font.postScriptName as String? ?? "HelveticaNeue"
    var error: Unmanaged<CFError>?
    CTFontManagerRegisterGraphicsFont(font, &error)
    return postScriptName
  }()
}

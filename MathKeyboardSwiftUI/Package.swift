// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "MathKeyboardSwiftUI",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(
      name: "MathKeyboardSwiftUI",
      targets: ["MathKeyboardSwiftUI"]
    )
  ],
  dependencies: [
    .package(path: "../MathEditorSwift")
  ],
  targets: [
    .target(
      name: "MathKeyboardSwiftUI",
      dependencies: [
        "MathEditorSwift"
      ],
      path: "Sources/MathKeyboardSwiftUI",
      resources: [.process("Resources")],
    )
  ]
)

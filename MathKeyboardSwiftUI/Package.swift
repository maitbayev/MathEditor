// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "MathKeyboardSwiftUI",
  defaultLocalization: "en",
  platforms: [.iOS(.v16), .macOS(.v11)],
  products: [
    .library(
      name: "MathKeyboardSwiftUI",
      targets: ["MathKeyboardSwiftUI"]
    )
  ],
  dependencies: [
    .package(path: "..")
  ],
  targets: [
    .target(
      name: "MathKeyboardSwiftUI",
      dependencies: [
        .product(name: "MathKeyboard", package: "MathEditor"),
        .product(name: "MathEditor", package: "MathEditor"),
      ],
      path: "Sources/MathKeyboardSwiftUI"
    )
  ]
)

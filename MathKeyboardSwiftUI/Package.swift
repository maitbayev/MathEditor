// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "MathKeyboardSwiftUI",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v11)],
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

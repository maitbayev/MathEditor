// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "MathEditor",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(
      name: "MathEditorSwift",
      targets: ["MathEditorSwift"]
    ),
    .library(
      name: "MathKeyboardSwift",
      targets: ["MathKeyboardSwift"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/maitbayev/iosMath.git", branch: "master")
  ],
  targets: [
    .target(
      name: "MathEditorSwift",
      dependencies: ["iosMath"]
    ),
    .testTarget(
      name: "MathEditorSwiftTests",
      dependencies: [
        "MathEditorSwift"
      ]
    ),
    .target(
      name: "MathKeyboardSwift",
      dependencies: [
        "MathEditorSwift"
      ],
      resources: [.process("Resources")]
    ),
  ]
)

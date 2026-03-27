// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "MathEditorSwift",
  platforms: [.iOS(.v13), .macOS(.v11)],
  products: [
    .library(
      name: "MathEditorSwift",
      targets: ["MathEditorSwift"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/maitbayev/iosMath.git", branch: "master"),
    .package(path: "..")
  ],
  targets: [
    .target(
      name: "MathEditorSwift",
      dependencies: ["iosMath"]
    ),
    .testTarget(
      name: "MathEditorSwiftTests",
      dependencies: [
        "MathEditorSwift",
        //"MathEditor"
      ]
    ),
  ]
)

// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "MathEditor",
  defaultLocalization: "en",
  platforms: [.iOS(.v13), .macOS(.v11)],
  products: [
    .library(
      name: "MathEditor",
      targets: ["MathEditor"]),
    .library(
      name: "MathKeyboard",
      targets: ["MathKeyboard"])
  ],
  dependencies: [
    .package(url: "https://github.com/maitbayev/iosMath.git", branch: "master")
  ],
  targets: [
    .target(
      name: "MathEditor",
      dependencies: [.product(name: "iosMath", package: "iosMath")],
      path: "./mathEditor",
      cSettings: [
        .headerSearchPath("./editor"),
        .headerSearchPath("./internal"),
      ]
    ),
    .target(
      name: "MathKeyboard",
      dependencies: [.product(name: "iosMath", package: "iosMath"), "MathEditor"],
      path: "./mathKeyboard",
      resources: [.process("MathKeyboardResources")],
      cSettings: [
        .headerSearchPath("./keyboard"),
      ]
    ),
    .testTarget(
      name: "MathEditorTests",
      dependencies: ["MathEditor"],
      path: "Tests",
      cSettings: [ 
        .headerSearchPath("../mathEditor/editor"),
        .headerSearchPath("../mathEditor/keyboard"),
        .headerSearchPath("../mathEditor/internal"),
      ]
    ),
  ]
)

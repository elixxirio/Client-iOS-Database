// swift-tools-version: 5.6
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .unsafeFlags(
    [
      "-Xfrontend",
      "-debug-time-function-bodies",
      "-Xfrontend",
      "-debug-time-expression-type-checking",
    ],
    .when(configuration: .debug)
  ),
]

let package = Package(
  name: "xx-client-ios-db",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "XXModels",
      targets: ["XXModels"]
    ),
    .library(
      name: "XXDatabase",
      targets: ["XXDatabase"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/groue/GRDB.swift",
      .upToNextMajor(from: "5.24.0")
    ),
  ],
  targets: [
    .target(
      name: "XXModels",
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXModelsTests",
      dependencies: [
        .target(name: "XXModels"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "XXDatabase",
      dependencies: [
        .target(
          name: "XXModels"
        ),
        .product(
          name: "GRDB",
          package: "GRDB.swift"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXDatabaseTests",
      dependencies: [
        .target(name: "XXDatabase"),
      ],
      swiftSettings: swiftSettings
    ),
  ]
)
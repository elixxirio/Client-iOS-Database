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
    .macOS(.v12),
  ],
  products: [
    .library(
      name: "XXModels",
      targets: ["XXModels"]
    ),
    .library(
      name: "XXLegacyDatabaseMigrator",
      targets: ["XXLegacyDatabaseMigrator"]
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
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump.git",
      .upToNextMajor(from: "0.4.0")
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
        .target(
          name: "XXModels"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "XXLegacyDatabaseMigrator",
      dependencies: [
        .target(
          name: "XXDatabase"
        ),
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
      name: "XXLegacyDatabaseMigratorTests",
      dependencies: [
        .target(
          name: "XXLegacyDatabaseMigrator"
        ),
        .product(
          name: "CustomDump",
          package: "swift-custom-dump"
        ),
      ],
      resources: [
        .copy("Resources/legacy_database_1.sqlite"),
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
        .target(
          name: "XXDatabase"
        ),
        .product(
          name: "CustomDump",
          package: "swift-custom-dump"
        ),
      ],
      swiftSettings: swiftSettings
    ),
  ]
)

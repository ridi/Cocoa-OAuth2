// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RidiOAuth2",
    platforms: [
        .iOS("9.3"),
        .macOS("10.13"),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RidiOAuth2",
            targets: ["RidiOAuth2"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/JanGorman/Hippolyte.git", .upToNextMajor(from: "1.0.0"))

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RidiOAuth2",
            dependencies: ["Alamofire", "RxSwift"]),
        .testTarget(
            name: "RidiOAuth2Tests",
            dependencies: ["RidiOAuth2", "Hippolyte"]),
    ]
)

// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "Defaults",
	platforms: [
		.macOS(.v10_12),
		.iOS(.v11),
		.tvOS(.v10),
		.watchOS(.v3)
	],
	products: [
		.library(
			name: "Defaults",
			targets: [
				"Defaults"
			]
		)
	],
	targets: [
		.target(
			name: "Defaults"
		)
	]
)

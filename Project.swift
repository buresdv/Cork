import ProjectDescription

let project = Project(
    name: "Cork",
    packages: [
        .remote(url: "https://github.com/SimplyDanny/SwiftLintPlugins", requirement: .upToNextMajor(from: "0.56.2")),
    ],
    settings: .settings(
        configurations: [
            .debug(
                name: "Debug",
                xcconfig: .relativeToRoot("xcconfigs/Project.xcconfig")
            ),
            .release(
                name: "Release",
                xcconfig: .relativeToRoot("xcconfigs/Project.xcconfig")
            ),
        ]),
    targets: [
        .target(
            name: "Cork",
            destinations: [.mac],
            product: .app,
            bundleId: "com.davidbures.cork",
            infoPlist: .file(path: "Cork/Info.plist"),
            sources: [
                "Cork/**/*.swift",
            ], resources: [
                "Cork/**/*.xcassets",
                "Cork/**/*.xcstrings",
                "PrivacyInfo.xcprivacy",
                "Cork/Logic/Helpers/Programs/Sudo Helper",
            ], dependencies: [
                // .target(name: "CorkHelp"),
                .target(name: "CorkShared"),
                .target(name: "CorkNotifications"),
                .external(name: "LaunchAtLogin"),
                .external(name: "DavidFoundation"),
                .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
            ], settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
                ),
                .release(
                    name: "Release",
                    xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
                ),
            ])
        ),
        .target(
            name: "CorkShared",
            destinations: [.mac],
            product: .staticLibrary,
            bundleId: "com.davidbures.cork-shared",
            sources: [
                "Modules/Shared/**/*.swift"
            ],
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
                ),
                .release(
                    name: "Release",
                    xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
                )
            ])
        ),
        .target(
            name: "CorkNotifications",
            destinations: [.mac],
            product: .staticLibrary,
            bundleId: "com.davidbures.cork-notifications",
            sources: [
                "Modules/Notifications/**/*.swift"
            ],
            dependencies: [
                .target(name: "CorkShared")
            ],
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
                ),
                .release(
                    name: "Release",
                    xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
                )
            ])
        ),
        .target(
            name: "CorkHelp",
            destinations: [.mac],
            product: .bundle,
            bundleId: "com.davidbures.corkhelp",
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    xcconfig: .relativeToRoot("xcconfigs/CorkHelp.xcconfig")
                ),
                .release(
                    name: "Release",
                    xcconfig: .relativeToRoot("xcconfigs/CorkHelp.xcconfig")
                ),
            ])
        ),
    ],
    schemes: [
        .scheme(
            name: "Release",
            buildAction: .buildAction(
                targets: ["Cork"]
            ),
            runAction: .runAction(
                configuration: .release,
                executable: "Cork",
                options: .options(language: .init(identifier: "en"))
            )
        ),
        .scheme(
            name: "Self-Compiled",
            buildAction: .buildAction(
                targets: ["Cork"]
            ),
            runAction: .runAction(
                executable: "Cork",
                arguments: .arguments(
                    environmentVariables: [
                        "SELF_COMPILED": "true",
                    ]
                ),
                options: .options(language: .init(identifier: "en"))
            )
        ),
        .scheme(
            name: "Debug",
            buildAction: .buildAction(
                targets: ["Cork"]
            ),
            runAction: .runAction(
                configuration: .debug,
                executable: "Cork",
                options: .options(language: .init(identifier: "en"))
            )
        )
    ]
)

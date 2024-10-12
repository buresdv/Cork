import ProjectDescription

let settings = Environment.selfCompiled.getBoolean(default: false)

func corkTarget(configureWithSelfCompiled: Bool) -> ProjectDescription.Target {
    var additionalCompilationConditions = [String]()
    if configureWithSelfCompiled {
        additionalCompilationConditions.append ("SELF_COMPILED")
    }
    
    let targetName = configureWithSelfCompiled ? "Self-Compiled" : "Cork"
    
    return Target.target(
        name: targetName,
        destinations: [.mac],
        product: .app,
        productName: "Cork",
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
                settings: [:].swiftActiveCompilationConditions(["DEBUG"] + additionalCompilationConditions),
                xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
            ),
            .release(
                name: "Release",
                settings: [:].swiftActiveCompilationConditions(additionalCompilationConditions),
                xcconfig: .relativeToRoot("xcconfigs/Cork.xcconfig")
            ),
        ])
    )
}

let project = Project(
    name: "Cork",
    options: .options(
        automaticSchemesOptions: .enabled(runLanguage: "en"), 
        developmentRegion: "en"
    ),
    packages: [
        .remote(url: "https://github.com/SimplyDanny/SwiftLintPlugins", requirement: .upToNextMajor(from: "0.56.2")),
    ],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "MARKETING_VERSION": "1.4.5.3",
            "CURRENT_PROJECT_VERSION": "82"
        ],
        configurations: [
            .debug(
                name: "Debug",
//                settings: [:].swiftActiveCompilationConditions(["DEBUG"]),
                xcconfig: .relativeToRoot("xcconfigs/Project.xcconfig")
            ),
            .release(
                name: "Release",
                xcconfig: .relativeToRoot("xcconfigs/Project.xcconfig")
            ),
        ]),
    targets: [
        corkTarget(configureWithSelfCompiled: false),
        corkTarget(configureWithSelfCompiled: true),
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
        .target(
            name: "CorkTests",
            destinations: [.mac],
            product: .unitTests,
            bundleId: "com.davidbures.cork-tests",
            sources: [
                "Tests/**",
                "Cork/**/*.swift"
            ],
            dependencies: [
                .target(name: "Cork")
            ]
        )
    ]

)

import ProjectDescription

let settings = Environment.selfCompiled.getBoolean(default: false)

let version: Version = .init(1, 6, 2, buildMetadataIdentifiers: ["Sonoma"])
let build: String = "102_S"

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
        bundleId: "eu.davidbures.cork",
        deploymentTargets: .macOS("14.0.0"),
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
            .external(name: "ButtonKit"),
            .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
            .external(name: "Defaults"),
            .external(name: "DefaultsMacros")
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

let corkSharedTarget: ProjectDescription.Target = .target(
    name: "CorkShared",
    destinations: [.mac],
    product: .staticLibrary,
    bundleId: "eu.davidbures.cork-shared",
    deploymentTargets: .macOS("14.0.0"),
    sources: [
        "Modules/Shared/**/*.swift"
    ],
    dependencies: [
        .external(name: "Defaults")
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
)

let corkNotificationsTarget: ProjectDescription.Target = .target(
    name: "CorkNotifications",
    destinations: [.mac],
    product: .staticLibrary,
    bundleId: "eu.davidbures.cork-notifications",
    deploymentTargets: .macOS("14.0.0"),
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
)

let corkHelpTarget: ProjectDescription.Target = .target(
    name: "CorkHelp",
    destinations: [.mac],
    product: .bundle,
    bundleId: "eu.davidbures.corkhelp",
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
)

let corkTestsTarget: ProjectDescription.Target = .target(
    name: "CorkTests",
    destinations: [.mac],
    product: .unitTests,
    bundleId: "eu.davidbures.cork-tests",
    sources: [
        "Tests/**",
        "Cork/**/*.swift"
    ],
    dependencies: [
        .target(name: "Cork")
    ]
)

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
            "MARKETING_VERSION": .init(stringLiteral: version.description),
            "CURRENT_PROJECT_VERSION": .init(stringLiteral: build)
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
        corkSharedTarget,
        corkNotificationsTarget,
        corkHelpTarget,
        corkTestsTarget
    ]

)

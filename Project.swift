import ProjectDescription

let settings = Environment.selfCompiled.getBoolean(default: false)

let version: String = "1.7.4"
let build: String = "112"

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
            "Cork/AppIcon.icon"
        ], dependencies: [
            // .target(name: "CorkHelp"),
            .target(corkSharedTarget),
            .target(corkNotificationsTarget),
            .target(corkModelsTarget),
            .target(corkTerminalFunctionsTarget),
            .target(corkIntentsTarget),
            .external(name: "LaunchAtLogin"),
            .external(name: "DavidFoundation"),
            .external(name: "ApplicationInspector"),
            .external(name: "ButtonKit"),
            .external(name: "FactoryKit"),
            .external(name: "Defaults"),
            .external(name: "DefaultsMacros"),
            .package(product: "SwiftLintBuildToolPlugin", type: .plugin)
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
    resources: [
        "Cork/**/*.xcassets",
        "Cork/**/*.xcstrings",
        "PrivacyInfo.xcprivacy",
        "Cork/Logic/Helpers/Programs/Sudo Helper",
    ],
    dependencies: [
        .external(name: "Defaults"),
        .external(name: "FactoryKit")
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
        .target(corkSharedTarget)
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

let corkTerminalFunctionsTarget: ProjectDescription.Target = .target(
    name: "CorkTerminalFunctions",
    destinations: [.mac],
    product: .staticLibrary,
    bundleId: "eu.davidbures.cork-terminal-functions",
    deploymentTargets: .macOS("14.0.0"),
    sources: [
        "Modules/TerminalSupport/**/*.swift"
    ],
    dependencies: [
        .target(corkSharedTarget),
        .external(name: "FactoryKit")
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

let corkModelsTarget: ProjectDescription.Target = .target(
    name: "CorkModels",
    destinations: [.mac],
    product: .staticLibrary,
    bundleId: "eu.davidbures.cork-models",
    deploymentTargets: .macOS("14.0.0"),
    sources: [
        "Modules/Packages/PackagesModels/**/*.swift"
    ],
    resources: [
        "Cork/**/*.xcassets",
        "Cork/**/*.xcstrings",
        "PrivacyInfo.xcprivacy",
        "Cork/Logic/Helpers/Programs/Sudo Helper",
    ],
    dependencies: [
        .target(corkSharedTarget),
        .target(corkNotificationsTarget),
        .external(name: "FactoryKit"),
        .external(name: "Defaults"),
        .external(name: "DefaultsMacros"),
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

let corkIntentsTarget: ProjectDescription.Target = .target(
    name: "CorkIntents",
    destinations: [.mac],
    product: .staticLibrary,
    bundleId: "eu.davidbures.cork-intents",
    deploymentTargets: .macOS("14.0.0"),
    sources: [
        "Modules/Intents/**/*.swift"
    ],
    dependencies: [
        .target(corkSharedTarget),
        .external(name: "FactoryKit")
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
    deploymentTargets: .macOS("14.0.0"),
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
    deploymentTargets: .macOS("14.0.0"),
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
            "MARKETING_VERSION": .init(stringLiteral: version),
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
        corkTerminalFunctionsTarget,
        corkModelsTarget,
        corkIntentsTarget,
        corkNotificationsTarget,
        corkHelpTarget,
        corkTestsTarget
    ]

)

import ProjectDescription

let config: Config = .init(
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor(.init(26, 0, 0)),
        swiftVersion: .init(6, 0, 0),
        plugins: .init(),
        generationOptions: .options(),
        installOptions: .options())
)

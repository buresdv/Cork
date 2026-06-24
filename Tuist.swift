import ProjectDescription

let config: Config = .init(
    project: .tuist(
        compatibleXcodeVersions: .list([
            .upToNextMajor(.init(16, 0, 0)),
            .upToNextMajor(.init(27, 0, 0))
        ]),
        plugins: .init(),
        generationOptions: .options(),
        installOptions: .options()
    )
)

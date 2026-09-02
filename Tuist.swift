import ProjectDescription

let config: Config = .init(
    project: .tuist(
        compatibleXcodeVersions: .list([
            .upToNextMajor("16.0.0"),
            .upToNextMajor("26.0.0"),
            .upToNextMajor("27.0.0"),
        ]),
        plugins: .init(),
        generationOptions: .options(),
        installOptions: .options()
    )
)

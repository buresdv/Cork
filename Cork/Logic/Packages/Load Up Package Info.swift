//
//  Load Up Package Info.swift
//  Cork
//
//  Created by David Bureš on 19.07.2024.
//

import Foundation

enum BrewPackageInfoLoadingError: LocalizedError
{
    case didNotGetAnyTerminalOutput, standardErrorNotEmpty(presentError: String), couldNotConvertOutputToData, couldNotRetrievePackageFromOutput, couldNotDecodeOutput(presentError: String)

    var errorDescription: String?
    {
        switch self
        {
        case .didNotGetAnyTerminalOutput:
            return String(localized: "error.package-loading.no-terminal-output-returned")
        case .standardErrorNotEmpty(let presentError):
            return String(localized: "error.package-loading.standard-error-not-empty.\(presentError)")
        case .couldNotConvertOutputToData:
            return String(localized: "error.generic.couldnt-convert-string-to-data")
        case .couldNotRetrievePackageFromOutput:
            return String(localized: "error.package-loading-couldnt-get-package-from-parsed-output")
        case .couldNotDecodeOutput(let presentError):
            return String(localized: "error.generic-couldnt-decode-json.\(presentError)")
        }
    }
}

extension BrewPackage
{
    private struct PackageCommandOutput: Codable
    {
        struct Formulae: Codable
        {
            /// Name of the formula
            let name: String

            /// Description of the formula
            let desc: String

            /// Homepage of the formula
            let homepage: URL

            /// Tap the formula came from
            let tap: String

            /// Caveats specified for the formula
            let caveats: String?

            struct Installed: Codable
            {
                let installedAsDependency: Bool

                struct RuntimeDependencies: Codable
                {
                    /// Name of the dependency
                    let fullName: String

                    /// Version of the dependency
                    let version: String

                    /// Revision of the dependency
                    let revision: Int

                    /// Version of the dependency
                    let pkgVersion: String

                    /// Whether the dependency is a direct dependency of the package
                    let declaredDirectly: Bool
                }

                /// The dependencies of the package
                let runtimeDependencies: [RuntimeDependencies]?
            }

            /// Various info about the installation
            let installed: [Installed]

            /// Whether the package is outdated
            let outdated: Bool

            /// Whether the package is pinned
            let pinned: Bool?

            func extractDependencies() -> [BrewPackageDependency]?
            {
                let allDependencies = self.installed.flatMap
                { installed in
                    installed.runtimeDependencies ?? []
                }

                if allDependencies.isEmpty
                {
                    return nil
                }

                return allDependencies.map
                { dependency in
                    .init(name: dependency.fullName, version: dependency.version, directlyDeclared: dependency.declaredDirectly)
                }
            }
        }

        struct Casks: Codable
        {
            /// Name of the cask
            let token: String

            /// Description of the cask
            let desc: String

            /// Homepage of the cask
            let homepage: URL

            /// The tap the cask came from
            let tap: String

            /// Whether the cask was installed as dependency
            /// Always false, since Casks can't have dependencies or be dependants
            let installedAsDependency: Bool = false

            /// Whether the cas is outdated
            let outdated: Bool

            /// Caveats specified for the cask
            let caveats: String?

            /// Whether the cask is pinned
            let pinned: Bool?
        }

        let formulae: [Formulae]?
        let casks: [Casks]?

        /// Extract dependencies from the struct so they can be used
        func extractDependencies() -> [BrewPackageDependency]?
        {
            guard let formulae = self.formulae
            else
            {
                return nil
            }

            let allDependencies = formulae.flatMap
            { formula in
                formula.installed.flatMap
                { installed in
                    installed.runtimeDependencies ?? []
                }
            }

            if allDependencies.isEmpty
            {
                return nil
            }

            return allDependencies.map
            { dependency in
                .init(name: dependency.fullName, version: dependency.version, directlyDeclared: dependency.declaredDirectly)
            }
        }
    }

    /// Load package details
    @MainActor
    func loadDetails() async throws -> BrewPackageDetails
    {
        let decoder: JSONDecoder =
        {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        var rawOutput: TerminalOutput?

        switch self.type
        {
        case .formula:
            rawOutput = await shell(AppConstants.brewExecutablePath, ["info", "--json=v2", self.name])

        case .cask:
            rawOutput = await shell(AppConstants.brewExecutablePath, ["info", "--json=v2", "--cask", self.name])
        }

        // MARK: - Error checking

        guard let rawOutput
        else
        {
            AppConstants.logger.error("Did not get any terminal output from the package details loading function")

            throw BrewPackageInfoLoadingError.didNotGetAnyTerminalOutput
        }

        if !rawOutput.standardError.isEmpty
        {
            AppConstants.logger.warning("Standard error of the package details loading function is not empty. Will investigate if the error can be ignored.")

            if rawOutput.standardError.range(of: "(T|t)reating.*as a (formula|cask)", options: .regularExpression) != nil
            {
                AppConstants.logger.notice("The error of package details loading function was not serious enough to throw an error. Ignoring.")
            }
            else
            {
                AppConstants.logger.error("Error was serious enough to throw an error")

                throw BrewPackageInfoLoadingError.standardErrorNotEmpty(presentError: rawOutput.standardError)
            }
        }

        guard let decodableData: Data = rawOutput.standardOutput.data(using: .utf8, allowLossyConversion: false)
        else
        {
            AppConstants.logger.error("Could not convert string of package details loading function to data")

            throw BrewPackageInfoLoadingError.couldNotConvertOutputToData
        }

        // MARK: - Decoding

        do
        {
            let rawDecodedPackageInfo: PackageCommandOutput = try decoder.decode(PackageCommandOutput.self, from: decodableData)

            switch self.type
            {
            case .formula:
                guard let formulaInfo: PackageCommandOutput.Formulae = rawDecodedPackageInfo.formulae?.first
                else
                {
                    AppConstants.logger.error("Could not retrieve the relevant formula during formula details loading")

                    throw BrewPackageInfoLoadingError.couldNotRetrievePackageFromOutput
                }

                let dependencies: [BrewPackageDependency]? = formulaInfo.extractDependencies()

                return .init(
                    name: formulaInfo.name,
                    description: formulaInfo.desc,
                    homepage: formulaInfo.homepage,
                    tap: .init(name: formulaInfo.tap),
                    installedAsDependency: formulaInfo.installed.first?.installedAsDependency ?? false,
                    packageDependents: nil,
                    dependencies: dependencies,
                    outdated: formulaInfo.outdated,
                    caveats: formulaInfo.caveats,
                    pinned: formulaInfo.pinned
                )

            case .cask:
                guard let caskInfo: PackageCommandOutput.Casks = rawDecodedPackageInfo.casks?.first
                else
                {
                    AppConstants.logger.error("Could not retrieve the relevant cask during formula details loading")

                    throw BrewPackageInfoLoadingError.couldNotRetrievePackageFromOutput
                }

                return .init(
                    name: caskInfo.token,
                    description: caskInfo.desc,
                    homepage: caskInfo.homepage,
                    tap: .init(name: caskInfo.tap),
                    installedAsDependency: false,
                    packageDependents: nil,
                    dependencies: nil,
                    outdated: caskInfo.outdated,
                    caveats: caskInfo.caveats,
                    pinned: caskInfo.pinned
                )
            }
        }
        catch let brewDetailsLoadingError
        {
            AppConstants.logger.error("Failed while decoding package info: \(brewDetailsLoadingError)")

            throw BrewPackageInfoLoadingError.couldNotDecodeOutput(presentError: brewDetailsLoadingError.localizedDescription)
        }
    }
}

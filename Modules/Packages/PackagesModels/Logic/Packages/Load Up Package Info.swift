//
//  Load Up Package Info.swift
//  Cork
//
//  Created by David Bureš on 19.07.2024.
//

import CorkShared
import Foundation
import CorkTerminalFunctions

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
    struct PackageCommandOutput: Codable
    {
        // MARK: - Formulae

        struct Formulae: Codable
        {
            /// Name of the formula
            let name: String

            /// Description of the formula
            let desc: String?

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

            struct Bottle: Codable
            {
                struct Stable: Codable
                {
                    struct FileInfo: Codable
                    {
                        let cellar: URL
                        let url: URL
                        let sha256: String
                    }

                    /// The individual files
                    let files: [String: FileInfo]
                }

                /// The stable files
                let stable: Stable?
            }

            /// Info about the relevant files
            let bottle: Bottle

            /// Whether the package is outdated
            let outdated: Bool

            /// Whether the package is pinned
            let pinned: Bool

            /// Whether this package is considered deprecated
            let deprecated: Bool

            /// If deprecated, the reason for the package's deprecation
            let deprecationReason: String?

            // MARK: - Formuale functions

            func extractDependencies() -> [BrewPackageDependency]?
            {
                let allDependencies: [BrewPackage.PackageCommandOutput.Formulae.Installed.RuntimeDependencies] = installed.flatMap
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

            func getCompatibility() -> Bool?
            {
                guard let stable = bottle.stable
                else
                {
                    AppConstants.shared.logger.debug("Package \(name) has unknown compatibility")
                    return nil
                }
                for compatibleSystem in stable.files.keys
                {
                    if compatibleSystem.contains(AppConstants.shared.osVersionString.lookupName)
                    {
                        AppConstants.shared.logger.debug("Package \(name) is compatible")
                        return true
                    }
                }

                AppConstants.shared.logger.debug("Package \(name) is NOT compatible")
                return false
            }
        }

        // MARK: - Casks

        struct Casks: Codable
        {
            /// Name of the cask
            let token: String

            /// Description of the cask
            let desc: String?

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

            /// Whether this package is considered deprecated
            let deprecated: Bool

            /// If deprecated, the reason for the package's deprecation
            let deprecationReason: String?

            /// Names of the artifacts - which include the `.app` file name
            let artifacts: [Artifact]

            var executableName: String?
            {
                // Prefer app over pkg
                if let appName = artifacts.compactMap({ $0.app }).flatMap({ $0 }).first
                {
                    return appName
                }
                return artifacts.compactMap { $0.pkg }.flatMap { $0 }.first
            }

            struct Artifact: Codable
            {
                let app: [String]?
                let pkg: [String]?

                init(from decoder: Decoder) throws
                {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    app = try? container.decodeIfPresent([String].self, forKey: .app)
                    pkg = try? container.decodeIfPresent([String].self, forKey: .pkg)
                }

                enum CodingKeys: String, CodingKey
                {
                    case app, pkg
                }
            }
        }

        let formulae: [Formulae]?
        let casks: [Casks]?

        /// Extract dependencies from the struct so they can be used
        func extractDependencies() -> [BrewPackageDependency]?
        {
            guard let formulae = formulae
            else
            {
                return nil
            }

            let allDependencies: [BrewPackage.PackageCommandOutput.Formulae.Installed.RuntimeDependencies] = formulae.flatMap
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
    public func loadDetails() async throws -> BrewPackage.BrewPackageDetails
    {
        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        var rawOutput: TerminalOutput

        switch type
        {
        case .formula:
            rawOutput = await shell(AppConstants.shared.brewExecutablePath, ["info", "--json=v2", self.getPackageName(withPrecision: .precise)])

        case .cask:
            rawOutput = await shell(AppConstants.shared.brewExecutablePath, ["info", "--json=v2", "--cask", self.getPackageName(withPrecision: .precise)])
        }

        // MARK: - Error checking

        guard !rawOutput.standardOutput.isEmpty
        else
        {
            AppConstants.shared.logger.error("Did not get any terminal output from the package details loading function")

            throw BrewPackageInfoLoadingError.didNotGetAnyTerminalOutput
        }

        if !rawOutput.standardError.isEmpty
        {
            AppConstants.shared.logger.warning("Standard error of the package details loading function is not empty. Will investigate if the error can be ignored.")

            if rawOutput.standardError.range(of: "(T|t)reating.*as a (formula|cask)", options: .regularExpression) != nil
            {
                AppConstants.shared.logger.notice("The error of package details loading function was not serious enough to throw an error. Ignoring.")
            }
            else
            {
                AppConstants.shared.logger.error("Error was serious enough to throw an error")

                throw BrewPackageInfoLoadingError.standardErrorNotEmpty(presentError: rawOutput.standardError)
            }
        }

        AppConstants.shared.logger.debug("JSON output: \(rawOutput.standardOutput)")

        guard let decodableData: Data = rawOutput.standardOutput.data(using: .utf8, allowLossyConversion: false)
        else
        {
            AppConstants.shared.logger.error("Could not convert string of package details loading function to data")

            throw BrewPackageInfoLoadingError.couldNotConvertOutputToData
        }

        // MARK: - Decoding

        do
        {
            let rawDecodedPackageInfo: PackageCommandOutput = try decoder.decode(PackageCommandOutput.self, from: decodableData)

            switch type
            {
            case .formula:
                guard let formulaInfo: PackageCommandOutput.Formulae = rawDecodedPackageInfo.formulae?.first
                else
                {
                    AppConstants.shared.logger.error("Could not retrieve the relevant formula during formula details loading")

                    throw BrewPackageInfoLoadingError.couldNotRetrievePackageFromOutput
                }

                return .init(
                    name: formulaInfo.name,
                    description: formulaInfo.desc,
                    homepage: formulaInfo.homepage,
                    tap: .init(name: formulaInfo.tap),
                    installedAsDependency: formulaInfo.installed.first?.installedAsDependency ?? false,
                    dependencies: formulaInfo.extractDependencies(),
                    outdated: formulaInfo.outdated,
                    caveats: formulaInfo.caveats,
                    deprecated: formulaInfo.deprecated,
                    deprecationReason: formulaInfo.deprecationReason,
                    isCompatible: formulaInfo.getCompatibility()
                )

            case .cask:
                guard let caskInfo: PackageCommandOutput.Casks = rawDecodedPackageInfo.casks?.first
                else
                {
                    AppConstants.shared.logger.error("Could not retrieve the relevant cask during formula details loading")

                    throw BrewPackageInfoLoadingError.couldNotRetrievePackageFromOutput
                }

                return .init(
                    name: caskInfo.token,
                    description: caskInfo.desc,
                    homepage: caskInfo.homepage,
                    tap: .init(name: caskInfo.tap),
                    installedAsDependency: false,
                    dependencies: nil,
                    outdated: caskInfo.outdated,
                    caveats: caskInfo.caveats,
                    deprecated: caskInfo.deprecated,
                    deprecationReason: caskInfo.deprecationReason,
                    isCompatible: true
                )
            }
        }
        catch let brewDetailsLoadingError
        {
            AppConstants.shared.logger.error("Failed while decoding package info: \(brewDetailsLoadingError)")

            throw BrewPackageInfoLoadingError.couldNotDecodeOutput(presentError: brewDetailsLoadingError.localizedDescription)
        }
    }
}

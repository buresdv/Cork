//
//  Get Outdated Packages.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation
import SwiftUI

enum OutdatedPackageRetrievalError: LocalizedError
{
    case homeNotSet, couldNotDecodeCommandOutput(String), otherError(String)

    var errorDescription: String?
    {
        switch self
        {
        case .homeNotSet:
            return String(localized: "error.outdated-packages.home-not-set")
        case .couldNotDecodeCommandOutput(let string):
            return String(localized: "error.outdated-packages.could-not-decode-command-output.\(string)")
        case .otherError(let string):
            return String(localized: "error.outdated-packages.other-error.\(string)")
        }
    }
}

extension OutdatedPackageTracker
{
    /// This struct alows us to parse the JSON output of the outdated package function. It is not used outside this function
    fileprivate struct OutdatedPackageCommandOutput: Codable
    {
        struct Formulae: Codable
        {
            /// The name of the outdated package
            let name: String
            /// The installed versions, i.e. the outdated version
            let installedVersions: [String]
            /// The upstream version, i.e. the most up-to-date version
            let currentVersion: String
            let pinned: Bool
            let pinnedVersion: String?
        }

        struct Casks: Codable
        {
            /// The name of the outdated package
            let name: String
            /// The installed versions, i.e. the outdated version
            let installedVersions: [String]
            /// The upstream version, i.e. the most up-to-date version
            let currentVersion: String
        }

        let formulae: [Formulae]
        let casks: [Casks]
    }

    /// Load outdated packages into the outdated package tracker
    func getOutdatedPackages(brewData: BrewDataStorage, appState: AppState? = nil, packageArray _: [String]? = nil) async throws
    {
        /// Set the UI stuff if AppState has been passed
        if let appState
        {
            if appState.isCheckingForPackageUpdates == false
            {
                appState.isCheckingForPackageUpdates = true
            }
        }

        defer
        {
            if let appState
            {
                withAnimation
                {
                    appState.isCheckingForPackageUpdates = false
                }
            }
        }
        let rawOutput: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["outdated", "--json=v2"])

        // MARK: - Error checking

        if rawOutput.standardError.contains("HOME must be set")
        {
            AppConstants.logger.error("Encountered HOME error")
            throw OutdatedPackageRetrievalError.homeNotSet
        }

        if !rawOutput.standardError.isEmpty
        {
            AppConstants.logger.error("Standard error for package updating is not empty: \(rawOutput.standardError)")
            throw OutdatedPackageRetrievalError.otherError(rawOutput.standardError)
        }

        // MARK: - Decoding

        let outdatedPackagesOutputDecoder: JSONDecoder =
        {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        do
        {
            guard let decodableOutput: Data = rawOutput.standardOutput.data(using: .utf8, allowLossyConversion: false)
            else
            {
                AppConstants.logger.error("Could not convert raw output of decoding function to data for the decoder")

                throw OutdatedPackageRetrievalError.otherError("There was a failure encoding data")
            }
            let rawDecodedOutdatedPackages: OutdatedPackageCommandOutput = try outdatedPackagesOutputDecoder.decode(OutdatedPackageCommandOutput.self, from: decodableOutput)

            // MARK: - Outdated package matching

            async let finalOutdatedFormulae: Set<OutdatedPackage> = await getOutdatedFormulae(from: rawDecodedOutdatedPackages.formulae, brewData: brewData)
            async let finalOutdatedCasks: Set<OutdatedPackage> = await getOutdatedCasks(from: rawDecodedOutdatedPackages.casks, brewData: brewData)

            self.outdatedPackages = await finalOutdatedFormulae.union(finalOutdatedCasks)
        }
        catch let decodingError
        {
            AppConstants.logger.error("There was an error decoding the outdated package retrieval output: \(decodingError.localizedDescription, privacy: .public)\n\(decodingError, privacy: .public)")
            throw OutdatedPackageRetrievalError.couldNotDecodeCommandOutput(decodingError.localizedDescription)
        }
    }

    // MARK: - Helper functions

    private func getOutdatedFormulae(from intermediaryArray: [OutdatedPackageCommandOutput.Formulae], brewData: BrewDataStorage) async -> Set<OutdatedPackage>
    {
        var finalOutdatedFormulaTracker: Set<OutdatedPackage> = .init()

        for outdatedFormula in intermediaryArray
        {
            if let foundOutdatedFormula = brewData.installedFormulae.first(where: { $0.name == outdatedFormula.name })
            {
                finalOutdatedFormulaTracker.insert(.init(
                    package: foundOutdatedFormula,
                    installedVersions: outdatedFormula.installedVersions,
                    newerVersion: outdatedFormula.currentVersion
                )
                )
            }
        }

        return finalOutdatedFormulaTracker
    }

    private func getOutdatedCasks(from intermediaryArray: [OutdatedPackageCommandOutput.Casks], brewData: BrewDataStorage) async -> Set<OutdatedPackage>
    {
        var finalOutdatedCaskTracker: Set<OutdatedPackage> = .init()

        for outdatedCask in intermediaryArray
        {
            if let foundOutdatedCask = brewData.installedCasks.first(where: { $0.name == outdatedCask.name })
            {
                finalOutdatedCaskTracker.insert(.init(
                    package: foundOutdatedCask,
                    installedVersions: outdatedCask.installedVersions,
                    newerVersion: outdatedCask.currentVersion
                )
                )
            }
        }

        return finalOutdatedCaskTracker
    }
}

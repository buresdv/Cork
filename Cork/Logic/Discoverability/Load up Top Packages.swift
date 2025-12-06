//
//  Load up Top Packages.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import CorkShared
import CorkModels

enum TopPackageLoadingError: LocalizedError
{
    case couldNotDownloadData, couldNotDecodeTopFormulae(error: String), couldNotDecodeTopCasks(error: String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotDownloadData:
            return String(localized: "error.top-packages.could-not-download-data")
        case .couldNotDecodeTopFormulae(let error):
            return String(localized: "error.top-packages.could-not-decode-formulae.\(error)")
        case .couldNotDecodeTopCasks(let error):
            return String(localized: "error.top-packages.could-not-decode-casks.\(error)")
        }
    }
}

extension TopPackagesTracker
{
    func loadTopPackages(numberOfDays: Int = 30, appState: AppState) async
    {
        /// The magic number here is the result of 1000/30, a base limit for 30 days: If the user selects the number of days to be 30, only show packages with more than 1000 downloads
        let packageDownloadsCutoff: Int = 33 * numberOfDays

        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        async let topFormulae: [BrewPackage] = await loadTopFormulae(numberOfDays: numberOfDays, downloadsCutoff: packageDownloadsCutoff, decoder: decoder)
        async let topCasks: [BrewPackage] = await loadTopCasks(numberOfDays: numberOfDays, downloadsCutoff: packageDownloadsCutoff, decoder: decoder)

        do
        {
            self.topFormulae = try await topFormulae
        }
        catch let topFormulaeLoadingError
        {
            appState.showAlert(errorToShow: .couldNotParseTopPackages(error: topFormulaeLoadingError.localizedDescription))
            appState.failedWhileLoadingTopPackages = true
        }

        do
        {
            self.topCasks = try await topCasks
        }
        catch let topCasksLoadingError
        {
            appState.showAlert(errorToShow: .couldNotParseTopPackages(error: topCasksLoadingError.localizedDescription))
            appState.failedWhileLoadingTopPackages = true
        }
    }

    // MARK: - Loading top formulae

    private func loadTopFormulae(numberOfDays: Int, downloadsCutoff: Int, decoder: JSONDecoder) async throws -> [BrewPackage]
    {
        struct TopFormulaeOutput: Codable
        {
            struct Items: Codable
            {
                /// Name of the formula
                let formula: String

                /// Number of downloads, as String
                let count: String
            }

            /// The formulae themselves
            let items: [Items]
        }

        let statsURL: URL = .init(string: "https://formulae.brew.sh/api/analytics/install/\(numberOfDays)d.json")!

        do
        {
            let jsonResponse: Data = try await downloadDataFromURL(statsURL)

            do
            {
                let decodedTopFormulae: TopFormulaeOutput = try decoder.decode(TopFormulaeOutput.self, from: jsonResponse)

                return decodedTopFormulae.items.compactMap
                { rawTopFormula in
                    let normalizedDownloadNumber: Int = .init(rawTopFormula.count.replacingOccurrences(of: ",", with: "")) ?? 0

                    if normalizedDownloadNumber > downloadsCutoff
                    {
                        return .init(
                            name: rawTopFormula.formula,
                            type: .formula,
                            installedOn: nil,
                            versions: .init(),
                            url: nil,
                            sizeInBytes: nil,
                            downloadCount: normalizedDownloadNumber
                        )
                    }
                    else
                    {
                        return nil
                    }
                }
            }
            catch let topFormulaeDecodingError
            {
                AppConstants.shared.logger.error("Failed while decoding top formulae: \(topFormulaeDecodingError)")
                throw TopPackageLoadingError.couldNotDecodeTopFormulae(error: topFormulaeDecodingError.localizedDescription)
            }
        }
        catch let dataDownloadingError
        {
            AppConstants.shared.logger.error("Failed while retrieving top formulae: \(dataDownloadingError.localizedDescription)")
            throw TopPackageLoadingError.couldNotDownloadData
        }
    }

    // MARK: - Loading top casks

    private func loadTopCasks(numberOfDays: Int, downloadsCutoff: Int, decoder: JSONDecoder) async throws -> [BrewPackage]
    {
        struct TopCasksOutput: Codable
        {
            struct Items: Codable
            {
                /// The name of the cask
                let cask: String

                /// Number of downloads, as String
                let count: String
            }

            /// The casks themselves
            let items: [Items]
        }

        let statsURL: URL = .init(string: "https://formulae.brew.sh/api/analytics/cask-install/\(numberOfDays)d.json")!

        do
        {
            let jsonResponse: Data = try await downloadDataFromURL(statsURL)

            do
            {
                let decodedTopCasks: TopCasksOutput = try decoder.decode(TopCasksOutput.self, from: jsonResponse)

                return decodedTopCasks.items.compactMap
                { rawTopCask in
                    let normalizedDownloadNumber: Int = .init(rawTopCask.count.replacingOccurrences(of: ",", with: "")) ?? 0

                    if normalizedDownloadNumber > downloadsCutoff
                    {
                        return .init(
                            name: rawTopCask.cask,
                            type: .cask,
                            installedOn: nil,
                            versions: .init(),
                            url: nil,
                            sizeInBytes: nil,
                            downloadCount: normalizedDownloadNumber
                        )
                    }
                    else
                    {
                        return nil
                    }
                }
            }
            catch let topCasksDecodingError
            {
                AppConstants.shared.logger.error("Failed while decoding top casks: \(topCasksDecodingError)")
                throw TopPackageLoadingError.couldNotDecodeTopCasks(error: topCasksDecodingError.localizedDescription)
            }
        }
        catch let dataDownloadingError
        {
            AppConstants.shared.logger.error("Failed while retrieving top casks: \(dataDownloadingError.localizedDescription)")
            throw TopPackageLoadingError.couldNotDownloadData
        }
    }
}

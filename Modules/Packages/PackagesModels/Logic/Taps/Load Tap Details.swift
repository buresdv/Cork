//
//  Load Tap Details.swift
//  Cork
//
//  Created by David Bureš - P on 11.03.2026.
//

import CorkShared
import CorkTerminalFunctions
import Foundation

public extension BrewTap
{
    enum TapInfoLoadingError: LocalizedError
    {
        case noJsonReturned
        case couldNotDownloadJson(error: Error)
        case couldNotReadJson
        case couldNotDecodeJson(error: TapInfo.JSONParsingError)

        public var errorDescription: String?
        {
            switch self
            {
            case .noJsonReturned:
                return String(localized: "error.tap-info-loading.json-output-empty")
            case .couldNotDownloadJson(let error):
                return error.localizedDescription
            case .couldNotReadJson:
                return String(localized: "error.tap-info-loading.could-not-read-json")
            case .couldNotDecodeJson(let error):
                return error.localizedDescription
            }
        }
    }

    func loadDetails() async throws(BrewTap.TapInfoLoadingError) -> TapInfo
    {
        appConstants.logger.info("Will start loading tap details for tap \(self.name(withPrecision: .full))")

        defer
        {
            appConstants.logger.info("Finished loading of tap info")

            self.setBeingLoadedStatus(to: false)
        }

        self.setBeingLoadedStatus(to: true)

        var tapInfoRaw: Data
        
        switch self.nameInternal.repo {
        case .homebrew:
            tapInfoRaw = try await self.loadTapJSONDataForFirstPartyTap()
        case .external(let name):
            tapInfoRaw = try await self.loadTapJSONDataForThirdPartyTap()
        }

        do
        {
            self.setBeingLoadedStatus(to: false)

            return try await .init(from: tapInfoRaw)
        }
        catch let tapDetailsInitializationError
        {
            self.setBeingLoadedStatus(to: false)

            throw .couldNotDecodeJson(error: tapDetailsInitializationError)
        }
    }

    /// Load and parse JSON into Data for first-party taps.
    ///
    /// The first-party taps are too big and hit the shell output overflow limit, so we have to load them from the JSON api
    private func loadTapJSONDataForFirstPartyTap() async throws(BrewTap.TapInfoLoadingError) -> Data
    {
        var infoRetrievalURL: URL
        
        if self.nameInternal.tapName == "core"
        { // URL for Core
            infoRetrievalURL = .init(string: "https://formulae.brew.sh/api/formula.json")!
        }
        else
        { // URL for Cask
            infoRetrievalURL = .init(string: "https://formulae.brew.sh/api/cask.json")!
        }
        
        do
        {
            let downloadedData: Data = try await downloadDataFromURL(infoRetrievalURL)
            
            let downloadedDataAsString: String = String(data: downloadedData, encoding: .utf8)!
            
            appConstants.logger.info("Result of tap info: \(downloadedDataAsString))")
            
            return downloadedData
        } catch let jsonDownloadingError {
            throw .couldNotDownloadJson(error: jsonDownloadingError)
        }
    }

    /// Load and parse JSON into Data for third-party taps.
    ///
    /// We have to use the built-in commands, because these taps are still hosted on GitHub and don't have APIs
    private func loadTapJSONDataForThirdPartyTap() async throws(BrewTap.TapInfoLoadingError) -> Data
    {
        let tapInfoLoadingResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["tap-info", "--json", self.name(withPrecision: .full)])

        appConstants.logger.info("Result of tap info: \(tapInfoLoadingResult)")

        guard !tapInfoLoadingResult.isEmpty
        else
        {
            appConstants.logger.error("There was no JSON in tap info call for tap \(self.name(withPrecision: .full))")

            throw .noJsonReturned
        }

        guard let tapInfoRaw: Data = tapInfoLoadingResult.getJsonFromOutput(failOnAnyErrorsPresent: false)
        else
        {
            throw .couldNotReadJson
        }

        return tapInfoRaw
    }
}

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
        case taskCancelled

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
            case .taskCancelled:
                return String(localized: "error.task-cancelled")
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

        switch self.nameInternal.repo
        {
        case .homebrew:
            tapInfoRaw = try await self.loadTapJSONDataForFirstPartyTap()
        case .external:
            tapInfoRaw = try await self.loadTapJSONDataForThirdPartyTap()
        }

        switch self.nameInternal.repo
        {
        case .homebrew:
            struct SpeakeasyResponse: Decodable
            {
                let packageFullName: String

                private enum CodingKeys: String, CodingKey
                {
                    case fullName
                    case fullToken
                }

                init(from decoder: Decoder) throws
                {
                    let container = try decoder.container(keyedBy: CodingKeys.self)

                    if let fullName = try? container.decode(String.self, forKey: .fullName)
                    {
                        packageFullName = fullName
                    }
                    else if let fullToken = try? container.decode(String.self, forKey: .fullToken)
                    {
                        packageFullName = fullToken
                    }
                    else
                    {
                        throw DecodingError.keyNotFound(
                            CodingKeys.fullName,
                            DecodingError.Context(
                                codingPath: decoder.codingPath,
                                debugDescription: "The JSON doesn't contain 'full_name' or 'full_token'."
                            )
                        )
                    }
                }
            }

            let speakeasyDecoder: JSONDecoder = {
                let decoder: JSONDecoder = .init()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }()

            guard let decodedSpeakeasyResponse = try? speakeasyDecoder.decode([SpeakeasyResponse].self, from: tapInfoRaw)
            else
            {
                throw TapInfoLoadingError.couldNotDecodeJson(error: .couldNotDecode(failureReason: "Could not decode Speakeasy response"))
            }

            return await .init(builtInTapType: self.nameInternal.tapName == "core" ? .formula : .cask, includedPackages: decodedSpeakeasyResponse.map(\.packageFullName))

        case .external:
            do
            {
                appConstants.logger.info("got valid data from JSON output: \(tapInfoRaw)")

                self.setBeingLoadedStatus(to: false)

                return try await .init(from: tapInfoRaw)
            }
            catch let tapDetailsInitializationError
            {
                self.setBeingLoadedStatus(to: false)

                throw .couldNotDecodeJson(error: tapDetailsInitializationError)
            }
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
            infoRetrievalURL = .init(string: "https://packages.homebrew.corkmac.app/formulae")!
        }
        else
        { // URL for Cask
            infoRetrievalURL = .init(string: "https://packages.homebrew.corkmac.app/casks")!
        }

        do
        {
            let downloadedData: Data = try await downloadDataFromURL(infoRetrievalURL)

            appConstants.logger.info("Downloaded data size: \(downloadedData.count)")

            return downloadedData
        }
        catch let jsonDownloadingError
        {
            throw .couldNotDownloadJson(error: jsonDownloadingError)
        }
    }

    /// Load and parse JSON into Data for third-party taps.
    ///
    /// We have to use the built-in commands, because these taps are still hosted on GitHub and don't have APIs
    private func loadTapJSONDataForThirdPartyTap() async throws(BrewTap.TapInfoLoadingError) -> Data
    {
        let tapInfoLoadingResult: [TerminalOutput] = await shell(appConstants.brewExecutablePath, ["tap-info", "--json", self.name(withPrecision: .full)])

        appConstants.logger.info("Result of tap info for tap \(self.name(withPrecision: .full)): \(tapInfoLoadingResult)")

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

//
//  Load Tap Details.swift
//  Cork
//
//  Created by David Bureš - P on 11.03.2026.
//

import CorkTerminalFunctions
import Foundation
import CorkShared

public extension BrewTap
{
    enum TapInfoLoadingError: LocalizedError
    {
        case noJsonReturned
        case couldNotReadJson
        case couldNotDecodeJson(error: TapInfo.JSONParsingError)
        
        public var errorDescription: String?
        {
            switch self
            {
            case .noJsonReturned:
                return String(localized: "error.tap-info-loading.json-output-empty")
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

        let tapInfoLoadingResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["tap-info", "--json", self.name(withPrecision: .full)])
        
        appConstants.logger.info("Result of tap info: \(tapInfoLoadingResult)")
        
        guard !tapInfoLoadingResult.isEmpty else
        {
            appConstants.logger.error("There was no JSON in tap info call for tap \(self.name(withPrecision: .full))")
            
            throw .noJsonReturned
        }
        
        guard let tapInfoRaw: Data = tapInfoLoadingResult.getJsonFromOutput(failOnAnyErrorsPresent: false)
        else
        {
            throw .couldNotReadJson
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
}

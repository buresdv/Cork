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
        case couldNotReadJson
        case couldNotDecodeJson(error: TapInfo.JSONParsingError)
    }

    func loadDetails() async throws(BrewTap.TapInfoLoadingError) -> TapInfo
    {
        self.setBeingLoadedStatus(to: true)

        guard let tapInfoRaw: Data = await shell(AppConstants.shared.brewExecutablePath, ["tap-info", "--json", self.name(withPrecision: .full)]).getJsonFromOutput(failOnAnyErrorsPresent: false)
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

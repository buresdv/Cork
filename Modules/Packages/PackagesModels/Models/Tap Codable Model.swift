//
//  Tap Codable Model.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation
import CorkModels

/// Decodable tap info
public struct TapInfo: Codable
{
    public init(from jsonData: Data) async throws(JSONParsingError)
    {
        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        do
        {
            let decodedTapInfo = try decoder.decode([TapInfo].self, from: jsonData)
            
            guard let relevantTapInfo = decodedTapInfo.first else
            {
                throw JSONParsingError.couldNotGetRelevantTapInfo
            }
            
            self = relevantTapInfo
            
        } catch let jsonDecodingError
        {
            throw .couldNotDecode(failureReason: jsonDecodingError.localizedDescription)
        }
    }
    
    /// The name of the tap
    public let name: String

    /// The user responsible for the tap
    public let user: String

    /// Name of the upstream repo
    public let repo: String

    /// Path to the tap
    public let path: URL

    /// Whether the tap is currently added
    public let installed: Bool

    /// Whether the tap is from the Homebrew developers
    public let official: Bool

    // MARK: - The contents of the tap

    /// The formulae included in the tap
    public let formulaNames: [String]

    /// The casks included in the tap
    public let caskTokens: [String]

    /// The paths to the formula files
    public let formulaFiles: [URL]?

    /// The paths to the cask files
    public let caskFiles: [URL]?

    /// No idea, honestly
    public let commandFiles: [String]?

    /// Link to the actual repo
    public let remote: URL?

    /// IDK
    public let customRemote: Bool?

    public var numberOfPackages: Int
    {
        return self.formulaNames.count + self.caskTokens.count
    }

    /// Formulae that include the package type. Useful for rpeviewing packages.
    public var includedFormulaeWithAdditionalMetadata: [MinimalHomebrewPackage]
    {
        return formulaNames.map
        { formulaName in
            .init(name: formulaName, type: .formula, installedIntentionally: false)
        }
    }

    public var includedCasksWithAdditionalMetadata: [MinimalHomebrewPackage]
    {
        return caskTokens.map
        { caskName in
            .init(name: caskName, type: .cask, installedIntentionally: false)
        }
    }
}


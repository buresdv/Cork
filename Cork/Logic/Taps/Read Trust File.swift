//
//  Read Trust File.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import CorkModels
import CorkShared
import Foundation

public struct TrustFileContents: Codable
{
    public var trustedTaps: [String]
    public var trustedFormulae: [String]
    public var trustedCasks: [String]
    public var trustedCommands: [String]?

    // TODO: Implement the actual type-safe names
    /*
     public var trustedTaps: [BrewTap.BrewTapName]
     public var trustedFormulae: [BrewPackageName]
     public var trustedCasks: [BrewPackageName]
     public var trustedCommands: [BrewPackageName]
      */

    public init(trustedTaps: [String], trustedFormulae: [String], trustedCasks: [String], trustedCommands: [String]) async
    {
        self.trustedTaps = trustedTaps
        self.trustedFormulae = trustedFormulae
        self.trustedCasks = trustedCasks
        self.trustedCommands = trustedCommands
    }

    public init()
    {
        self.trustedTaps = .init()
        self.trustedFormulae = .init()
        self.trustedCasks = .init()
        self.trustedCommands = .init()
    }

    enum CodingKeys: String, CodingKey
    {
        case trustedTaps = "trustedtaps"
        case trustedFormulae = "trustedformulae"
        case trustedCasks = "trustedcasks"
        case trustedCommands = "trustedcommands"
    }

    static let trustFileDecoder: JSONDecoder = {
        let trustFileDecoder: JSONDecoder = .init()

        return trustFileDecoder
    }()
}

public extension TapTracker
{
    enum TrustFileReadingError: LocalizedError
    {
        case couldNotOpenFile(error: Error)
        case couldNotDecodeFileContents(error: Error)

        public var errorDescription: String?
        {
            switch self
            {
            case .couldNotOpenFile(let error):
                return error.localizedDescription

            case .couldNotDecodeFileContents(let error):
                if let decodingError = error as? DecodingError
                {
                    return decodingError.rawDebugDescription
                }

                return String(describing: error)
            }
        }
    }

    func readTrustFile() async throws(TrustFileReadingError) -> TrustFileContents
    {
        guard let trustFilePath: URL = AppConstants.shared.tapTrustPath
        else
        {
            return .init()
        }

        do
        {
            let trustFileContentsRaw: Data = try .init(contentsOf: trustFilePath, options: .mappedIfSafe)

            do
            {
                let parsedTrustFile: TrustFileContents = try TrustFileContents.trustFileDecoder.decode(TrustFileContents.self, from: trustFileContentsRaw)

                print("Read trust file: \(parsedTrustFile)")

                return parsedTrustFile
            }
            catch let trustFileParsingError
            {
                throw TrustFileReadingError.couldNotDecodeFileContents(error: trustFileParsingError)
            }
        }
        catch let trustFileReadingError
        {
            throw TrustFileReadingError.couldNotOpenFile(error: trustFileReadingError)
        }
    }
}

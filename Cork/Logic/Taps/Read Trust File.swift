//
//  Read Trust File.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import CorkModels
import CorkShared
import Foundation
import FactoryKit

public struct TrustFileContentsCodable: Codable
{
    public var trustedTaps: [String]?
    public var trustedFormulae: [String]?
    public var trustedCasks: [String]?
    public var trustedCommands: [String]?

    public init(
        trustedTapsRaw: [String]?,
        trustedFormulaeRaw: [String]?,
        trustedCasksRaw: [String]?,
        trustedCommandsRaw: [String]?
    ) async {
        self.trustedTaps = trustedTapsRaw
        self.trustedFormulae = trustedFormulaeRaw
        self.trustedCasks = trustedCasksRaw
        self.trustedCommands = trustedCommandsRaw
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

public struct TrustFileContents
{
    @Injected(\.appConstants) var appConstants: AppConstants

    public var trustedTaps: [BrewTap.BrewTapName]?
    // TODO: Implement the rest
    
    public init(from decodedFileContents: TrustFileContentsCodable) async {
        self.trustedTaps = await self.convertRawTrustedTapsToInternalObjects(decodedFileContents.trustedTaps)
    }
    
    public init() {
        self.trustedTaps = .init()
    }
}

private extension TrustFileContents
{
    /// Convert raw tap names to internal objects that can be compared, exported, etc.
    func convertRawTrustedTapsToInternalObjects(_ rawTapArray: [String]?) async -> [BrewTap.BrewTapName]
    {
        guard let rawTaps = rawTapArray else {
            appConstants.logger.info("No trusted taps to parse")
            return .init()
        }
        
        return rawTaps.compactMap { rawTapName in
            do
            {
                let initializedTapName: BrewTap.BrewTapName = try .init(tapNameString: rawTapName)
                
                return initializedTapName
            } catch let tapInitializationError {
                appConstants.logger.error("Failed while parsing tap in trusted taps: \(tapInitializationError)")
                return nil
            }
        }
    }
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
    
    /// What part of the parsing failed - tells us whether the aprsing of trusted taps, formular, casks or commands failed
    enum TrustFileContentsErrorCategory: Sendable, Codable
    {
        case tap
        case formula
        case cask
        case command
    }
    
    enum TrustFileContentsParsingError: LocalizedError
    {
        case fieldDoesNotExist(category: TrustFileContentsErrorCategory)
        case fieldIsEmpty(category: TrustFileContentsErrorCategory)
        case couldNotInitializeInternalObject(category: TrustFileContentsErrorCategory, error: any Error)
        
        public var errorDescription: String?
        {
            switch self {
            case .fieldDoesNotExist(let category):
                switch category {
                case .tap:
                    return String(localized: "error.tap-trust.field-does-not-exist.tap")
                case .formula:
                    return String(localized: "error.tap-trust.field-does-not-exist.formula")
                case .cask:
                    return String(localized: "error.tap-trust.field-does-not-exist.cask")
                case .command:
                    return String(localized: "error.tap-trust.field-does-not-exist.command")
                }
                
            case .fieldIsEmpty(let category):
                switch category {
                case .tap:
                    return String(localized: "error.tap-trust.field-is-empty.tap")
                case .formula:
                    return String(localized: "error.tap-trust.field-is-empty.formula")
                case .cask:
                    return String(localized: "error.tap-trust.field-is-empty.cask")
                case .command:
                    return String(localized: "error.tap-trust.field-is-empty.command")
                }
            case .couldNotInitializeInternalObject(let category, let error):
                switch category {
                case .tap:
                    return String(localized: "error.tap-trust.could-not-initialize-object.tap.\(error.localizedDescription)")
                case .formula:
                    return String(localized: "error.tap-trust.could-not-initialize-object.formula.\(error.localizedDescription)")
                case .cask:
                    return String(localized: "error.tap-trust.could-not-initialize-object.cask.\(error.localizedDescription)")
                case .command:
                    return String(localized: "error.tap-trust.could-not-initialize-object.command.\(error.localizedDescription)")
                }
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
                let parsedTrustFile: TrustFileContentsCodable = try TrustFileContentsCodable.trustFileDecoder.decode(TrustFileContentsCodable.self, from: trustFileContentsRaw)

                print("Read trust file: \(parsedTrustFile)")

                return await .init(from: parsedTrustFile)
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

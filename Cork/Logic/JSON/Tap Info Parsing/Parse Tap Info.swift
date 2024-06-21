//
//  Parse Tap Info.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation

func parseTapInfo(from rawJSON: String) async throws -> TapInfo?
{
    let decoder: JSONDecoder =
    {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    do
    {
        guard let jsonAsData: Data = rawJSON.data(using: .utf8, allowLossyConversion: false) else
        {
            AppConstants.logger.error("Could not convert tap JSON string into data")
            throw JSONParsingError.couldNotConvertStringToData(failureReason: nil)
        }
        
        return try decoder.decode([TapInfo].self, from: jsonAsData).first
        
    } catch let decodingError {
        AppConstants.logger.error("Failed while decoding tap info: \(decodingError.localizedDescription)\n-\(decodingError)")
        
        throw JSONParsingError.couldNotDecode(failureReason: decodingError.localizedDescription)
    }
}

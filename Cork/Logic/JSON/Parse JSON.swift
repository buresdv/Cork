//
//  Parse JSON.swift
//  Cork
//
//  Created by David Bureš on 26.02.2023.
//

import Foundation
import SwiftyJSON

enum JSONError: Error
{
    case parsingFailed
}

func parseJSON(from string: String) throws -> JSON
{
    let data: Data = string.data(using: .utf8, allowLossyConversion: false)!
    
    do
    {
        return try JSON(data: data)
    } catch let JSONParsingError as NSError
    {
        AppConstants.logger.error("JSON parsing failed: \(JSONParsingError.localizedDescription, privacy: .public)")
        throw JSONError.parsingFailed
    }
}

func parseJSON(from data: Data) async throws -> JSON
{
    do
    {
        return try JSON(data: data)
    }
    catch let JSONParsingError as NSError
    {
        AppConstants.logger.error("JSON parsing failed: \(JSONParsingError.localizedDescription, privacy: .public)")
        throw JSONError.parsingFailed
    }
}

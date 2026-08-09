//
//  Tap URL Formatter.swift
//  Cork
//
//  Created by David Bureš - P on 08.08.2026.
//

import Foundation
import SwiftUI

struct SlashEnforcedURLStyle: ParseableFormatStyle
{
    var parseStrategy: SlashEnforcedURLStrategy { SlashEnforcedURLStrategy() }

    func format(_ value: URL) -> String
    {
        let string = value.absoluteString
        return string.hasSuffix("/") ? string : string + "/"
    }
}

struct SlashEnforcedURLStrategy: ParseStrategy
{
    func parse(_ value: String) throws -> URL
    {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else
        {
            throw URLError(.badURL)
        }

        let candidates: [String] = [trimmed, trimmed + "/"]
        for candidate in candidates
        {
            if let url = URL(string: candidate), url.scheme != nil
            {
                return url
            }
        }
        throw URLError(.badURL)
    }
}

extension FormatStyle where Self == SlashEnforcedURLStyle
{
    static var urlEnforcingTrailingSlash: SlashEnforcedURLStyle
    {
        SlashEnforcedURLStyle()
    }
}

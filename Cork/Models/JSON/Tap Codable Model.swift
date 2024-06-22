//
//  Tap Codable Model.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation

/// Decodable tap info
struct TapInfo: Codable
{
    /// The name of the tap
    let name: String
    
    /// The user responsible for the tap
    let user: String
    
    /// Name of the upstream repo
    let repo: String
    
    /// Path to the tap
    let path: URL
    
    /// Whether the tap is currently added
    let installed: Bool
    
    /// Whether the tap is from the Homebrew developers
    let official: Bool
    
    // MARK: - The contents of the tap
    /// The formulae included in the tap
    let formulaNames: [String]
    
    /// The casks included in the tap
    let caskTokens: [String]
    
    /// The paths to the formula files
    let formulaFiles: [URL]
    
    /// The paths to the cask files
    let caskFiles: [URL]
    
    /// No idea, honestly
    let commandFiles: [String]
    
    /// Link to the actual repo
    let remote: URL
    
    /// IDK
    let customRemote: Bool
}

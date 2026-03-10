//
//  Tap Loading Error.swift
//  Cork
//
//  Created by David Bureš - P on 04.01.2025.
//

import Foundation

public enum TapLoadingError: LocalizedError, Hashable
{
    /// Could not read the folder that includes the taps
    case couldNotAccessParentTapFolder(errorDetails: String)
    
    /// Could not read a tap itself
    case couldNotReadTapFolderContents(errorDetails: String)
    
    /// Could not parse a String name into a brew name
    case couldNotParseTapName(errorDetails: String)
    
    public var errorDescription: String?
    {
        switch self {
        case .couldNotAccessParentTapFolder(let errorDetails):
            return errorDetails
        case .couldNotReadTapFolderContents(let errorDetails):
            return errorDetails
        case .couldNotParseTapName(let errorDetails):
            return errorDetails
        }
    }
}

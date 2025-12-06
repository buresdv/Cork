//
//  Package Synchronization Error.swift
//  Cork
//
//  Created by David Bureš - P on 15.01.2025.
//

import Foundation

public enum PackageSynchronizationError: LocalizedError
{
    case synchronizationReturnedNil
    
    public var errorDescription: String?
    {
        switch self
        {
        case .synchronizationReturnedNil:
            return String(localized: "error.package-synchronization.returned-nil")
        }
    }
}

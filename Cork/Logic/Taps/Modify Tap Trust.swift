//
//  Modify Tap Trust.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import Foundation
import CorkShared
import CorkModels

public extension TapTracker
{
    enum TapTrustModificationError: LocalizedError
    {
        case couldNotReadTrustFile(error: TapTracker.TrustFileReadingError)
    }
    
    func modifyTrust() async throws(TapTrustModificationError)
    {
        do
        {
            let contentsOfTrustFile: TrustFileContents = try await self.readTrustFile()
        } catch let trustFileReadingError {
            appState.showAlert(errorToShow: .generic(customMessage: trustFileReadingError.localizedDescription))
            
            throw .couldNotReadTrustFile(error: trustFileReadingError)
        }
    }
}

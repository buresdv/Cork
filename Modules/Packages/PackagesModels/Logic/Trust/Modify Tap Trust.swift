//
//  Modify Tap Trust.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import Foundation
import CorkShared
import FactoryKit
import CorkTerminalFunctions

public extension BrewTap
{
    enum TapTrustModificationError: LocalizedError
    {
        case unimplemented(error: [TerminalOutput])
        case implemented(ImplementedError)
        
        public enum ImplementedError: LocalizedError
        {
            case coultNotRetrievePointerToThisTapInTrustTracker
        }
    }
    
    func trustSelf() async throws(TapTrustModificationError)
    {
        
        guard var thisTapInTrustTracker: BrewTapName = Container.shared.trustTracker.resolve().trustedTapNames.first(where: { $0 == self.nameInternal }) else {
            throw .implemented(.coultNotRetrievePointerToThisTapInTrustTracker)
        }
        
        
    }
    
    enum TapTrustModificationWritingError: LocalizedError
    {
        
    }
    
    private func writeTapTrustModificationStatusToFile() async throws
    {
        
    }
}

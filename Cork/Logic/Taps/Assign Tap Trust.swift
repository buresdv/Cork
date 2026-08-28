//
//  Assign Tap Trust.swift
//  Cork
//
//  Created by David Bureš - P on 28.08.2026.
//

import Foundation
import CorkModels
import CorkShared

public extension TapTracker
{
    /// Take the parsed trust file and assign the loaded taps the appropriate trust
    func assignTapTrust(fromParsedTrustFile trustFile: TrustFileContents) async
    {
        guard let trustedTapNames: [BrewTap.BrewTapName] = trustFile.trustedTaps else {
            appConstants.logger.info("There are no taps in the trusted file, nothing to assign")
            
            return
        }
        
        for tapToChangeTrustFor in self.tapsEligibleForTrustModification.filter({ potentiallyEligibleTap in
            trustedTapNames.contains(potentiallyEligibleTap.nameInternal)
        }) {
            print("Change tap trust for: \(tapToChangeTrustFor.name(withPrecision: .full))")
            
            await tapToChangeTrustFor.changeTrust(to: .explicit(.trusted))
        }
    }
}

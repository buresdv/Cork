//
//  XATTR Handling.swift
//  CorkFeature_XattrHandling
//
//  Created by David Bureš - P on 12.10.2026.
//

import Foundation
import ApplicationInspector
import System
import XAttr
import CorkShared

public extension Application
{
    
    var isQuarantined: Bool
    {
        self.checkQuarantinedStatus()
    }
    
    func checkQuarantinedStatus() -> Bool
    {
        AppConstants.shared.logger.debug("Will try to discover quarantine status for \(self.name, privacy: .public)")
        
        guard let xattrsForApp: [String] = try? FilePath(stringLiteral: self.url.path).extendedAttributeNames() else
        {
            AppConstants.shared.logger.debug("Could not discover if is quarantined")
            return false
        }
        
        let xattrsAsSet: Set<String> = Set(xattrsForApp)
        
        let hasQuarantineAttribute: Bool = xattrsAsSet.contains("com.apple.quarantine")
        let passedGatekeeper: Bool = xattrsAsSet.contains("com.apple.provenance")
        
        if hasQuarantineAttribute && !passedGatekeeper
        {
            AppConstants.shared.logger.debug("IS QUARANTINED")
            return true
        }
        else
        {
            AppConstants.shared.logger.debug("IS NOT QUARANTINED")
            return false
        }
    }
    
    func removeQuarantine() throws -> Void
    {
        let filePath: FilePath = .init(stringLiteral: self.url.path)
        
        let xattrsForApp = try filePath.extendedAttributeNames()
        
        if xattrsForApp.contains("com.apple.quarantine")
        {
            AppConstants.shared.logger.debug("App \(self.name, privacy: .public) has the quarantine attribute - will proceed with removal")
            
            try filePath.removeExtendedAttribute(forName: "com.apple.quarantine")
        }
        else
        {
            AppConstants.shared.logger.debug("App \(self.name, privacy: .public) does not have the quarantine attribute - nothing to do")
        }
    }
}

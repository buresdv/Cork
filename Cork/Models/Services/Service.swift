//
//  Service.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation
import AppKit

struct HomebrewService: Identifiable, Hashable, Codable
{
    var id: UUID = UUID()
    
    let name: String
    var status: ServiceStatus
    
    let user: String?
    
    let location: URL
    
    let exitCode: Int?
    
    func revealInFinder()
    {
        location.revealInFinder(.openParentDirectoryAndHighlightTarget)
    }
}

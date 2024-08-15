//
//  Service.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import AppKit
import Foundation

struct HomebrewService: Identifiable, Hashable, Codable
{
    var id: UUID = .init()

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

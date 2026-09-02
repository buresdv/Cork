//
//  Service.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import AppKit
import Foundation
import SwiftUI

@Observable
public class HomebrewService: Identifiable, Codable, Equatable, Hashable, @unchecked Sendable
{
    init(name: String, status: ServiceStatus, user: String? = nil, location: URL, exitCode: Int? = nil)
    {
        self.id = .init()
        self.name = name
        self.status = status
        self.user = user
        self.location = location
        self.exitCode = exitCode
    }

    public var id: UUID

    public let name: String
    public var status: ServiceStatus

    public let user: String?

    public let location: URL

    public var exitCode: Int?

    public var details: ServiceDetails?
    
    var isLoadingDetails: Bool = true

    public func revealInFinder()
    {
        location.revealInFinder(.openParentDirectoryAndHighlightTarget)
    }

    func changeStatus(to newStatus: ServiceStatus)
    {
        self.status = newStatus
    }

    public static func == (lhs: HomebrewService, rhs: HomebrewService) -> Bool
    {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}

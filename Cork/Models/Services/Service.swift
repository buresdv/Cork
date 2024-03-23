//
//  Service.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

struct HomebrewService: Identifiable, Hashable, Codable
{
    var id: UUID = UUID()
    
    let name: String
    let status: ServiceStatus
    
    let user: String?
    
    let location: URL
    
    let exitCode: Int?
}

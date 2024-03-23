//
//  Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import Foundation

struct ServiceDetails: Hashable, Codable
{
    let loaded: Bool
    let schedulable: Bool
    let pid: Int?
    
    let rootDir: URL?
    let logPath: URL?
    let errorLogPath: URL?
}

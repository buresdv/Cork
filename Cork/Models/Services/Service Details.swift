//
//  Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import Foundation

struct ServiceDetails: Hashable, Codable
{
    let name: String
    let serviceName: String
    
    let running: Bool
    let loaded: Bool
    let schedulable: Bool
    
    let pid: Int?
    
    let exitCode: Int?
    
    let user: String?
    let status: ServiceStatus
    
    let file: URL?
    
    let command: URL?
    
    let workingDir: URL?
    let rootDir: URL?
    let logPath: URL?
    let errorLogPath: URL?
    
    let interval: String?
    let cron: String?
    
    // MARK: - Legacy stuff
    /*
    let loaded: Bool
    let schedulable: Bool
    let pid: Int?
    
    let rootDir: URL?
    let logPath: URL?
    let errorLogPath: URL?
     */
}

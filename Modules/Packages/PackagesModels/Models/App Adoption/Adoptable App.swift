//
//  Adoptable App.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import ApplicationInspector
import CorkShared

public extension BrewPackagesTracker
{
    /// A struct for holding a Cask's name and its executable
    struct AdoptableApp: Identifiable, Hashable, Sendable
    {
        public let id: UUID = .init()

        public let caskName: String
        public let appExecutable: String
        
        public let description: String?

        public let fullAppUrl: URL

        public var isMarkedForAdoption: Bool

        public var app: Application?

        public init(caskName: String, description: String?, appExecutable: String)
        {
            self.caskName = caskName
            self.appExecutable = appExecutable
            
            self.description = description

            self.fullAppUrl = URL.applicationDirectory.appendingPathComponent(appExecutable, conformingTo: .application)

            self.isMarkedForAdoption = true
        }

        public mutating func changeMarkedState()
        {
            self.isMarkedForAdoption.toggle()
        }

        public func constructAppBundle() async -> Application?
        {
            return try? .init(from: self.fullAppUrl)
        }
        
        public func excludeSelf() async
        {
            let excludedAppRepresentation: ExcludedAdoptableApp = .init(fromAdoptableApp: self)
            
            await excludedAppRepresentation.saveSelfToDatabase()
        }
        
        public func includeSelf() async
        {
            let excludedAppRepresentation: ExcludedAdoptableApp = .init(fromAdoptableApp: self)
            
            await excludedAppRepresentation.deleteSelfFromDatabase()
        }
    }
}

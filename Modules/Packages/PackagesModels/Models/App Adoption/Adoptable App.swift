//
//  Adoptable App.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import ApplicationInspector

public extension BrewPackagesTracker
{
    /// A struct for holding a Cask's name and its executable
    struct AdoptableApp: Identifiable, Hashable, Sendable
    {
        public let id: UUID = .init()

        let caskName: String
        let appExecutable: String
        
        let description: String?

        let fullAppUrl: URL

        var isMarkedForAdoption: Bool

        var app: Application?

        init(caskName: String, description: String?, appExecutable: String)
        {
            self.caskName = caskName
            self.appExecutable = appExecutable
            
            self.description = description

            self.fullAppUrl = URL.applicationDirectory.appendingPathComponent(appExecutable, conformingTo: .application)

            self.isMarkedForAdoption = true
        }

        mutating func changeMarkedState()
        {
            self.isMarkedForAdoption.toggle()
        }

        func constructAppBundle() async -> Application?
        {
            return try? .init(from: self.fullAppUrl)
        }
        
        func excludeSelf() async
        {
            let excludedAppRepresentation: BrewPackagesTracker.ExcludedAdoptableApp = .init(fromAdoptableApp: self)
            
            await excludedAppRepresentation.saveSelfToDatabase()
        }
        
        func includeSelf() async
        {
            let excludedAppRepresentation: BrewPackagesTracker.ExcludedAdoptableApp = .init(fromAdoptableApp: self)
            
            await excludedAppRepresentation.deleteSelfFromDatabase()
        }
    }
}

//
//  Adoptable App.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import ApplicationInspector
import CorkShared
import Foundation
import SwiftData
import SwiftUI

public extension BrewPackagesTracker
{
    /// A struct for holding a Cask's name and its executable
    struct AdoptableApp: Identifiable, Hashable, @unchecked Sendable // TODO: Remove this @unchecked
    {
        public let id: UUID = .init()

        /// A Cask which might be a match for the found executable
        @Observable
        public class AdoptionCandidate: Identifiable, Hashable, PackageNameDisplayable
        {
            /// The Cask name of the adoptable app - `discord-canary`
            public var internalName: BrewPackageName
            
            public let displayableType: BrewPackage.PackageType? = .cask

            /// Description for the cask of the installation candidate
            public let caskDescription: String?

            /// Whether this partcular adoption candidate is selected for adoption
            public var isSelectedForAdoption: Bool

            public init(caskName: String, caskDescription: String?)
            {
                self.caskDescription = caskDescription
                self.isSelectedForAdoption = true
                self.internalName = .init(from: caskName)
            }

            public nonisolated
            func hash(into hasher: inout Hasher)
            {
                hasher.combine(self.internalName)
            }

            public nonisolated
            static func == (rhs: AdoptionCandidate, lhs: AdoptionCandidate) -> Bool
            {
                return rhs.internalName == lhs.internalName
            }
            
            // MARK: - Conformance stuff
            // Safe to ignore
            @ViewBuilder
            public var previewSelfButton: some View
            {
                EmptyView()
            }
            
            @ViewBuilder
            public var openDetailForSelfButton: some View
            {
                EmptyView()
            }
            
            public func doubleClickAction()
            {
                // Do nothing
            }
            
            @ViewBuilder
            public var revealSelfInFinderButton: some View
            {
                EmptyView()
            }
        }

        public let adoptionCandidates: [AdoptionCandidate]

        public nonisolated
        var selectedAdoptionCandidate: AdoptionCandidate?
        {
            return self.adoptionCandidates.filter { $0.isSelectedForAdoption }.first
        }
        
        public var selectedAdoptionCandidateCaskName: String?
        {
            return self.selectedAdoptionCandidate?.name(withPrecision: .precise)
        }
        
        /// The name of the installed executable - `Discord.app`
        public let appExecutable: String

        /// Location of the executable
        public let fullAppUrl: URL

        public var isMarkedForAdoption: Bool

        public var app: Application?

        public init(
            adoptionCandidates: [AdoptableApp.AdoptionCandidate],
            appExecutable: String
        ) {
            self.adoptionCandidates = adoptionCandidates

            self.appExecutable = appExecutable

            self.fullAppUrl = URL.applicationDirectory.appendingPathComponent(appExecutable, conformingTo: .application)

            self.isMarkedForAdoption = true
        }

        public mutating func changeSelectedState()
        {
            self.isMarkedForAdoption.toggle()
        }

        public func constructAppBundle() async -> Application?
        {
            return try? .init(from: self.fullAppUrl)
        }

        @MainActor
        public func excludeSelf() async
        {
            let excludedAppRepresentation: ExcludedAdoptableApp = .init(fromAdoptableApp: self)

            excludedAppRepresentation.saveSelfToDatabase()
        }

        @MainActor
        public func includeSelf() async
        {
            let excludedAppRepresentation: ExcludedAdoptableApp = .init(fromAdoptableApp: self)

            excludedAppRepresentation.deleteSelfFromDatabase()
        }
    }
}

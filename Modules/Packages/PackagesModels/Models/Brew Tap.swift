//
//  Brew Tap.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public final class BrewTap: Identifiable, Hashable
{
    public struct BrewTapName: Hashable, Equatable, Sendable
    {
        public enum NameRetrievalPrecision: Sendable
        {
            /// All parts: `marsanne/cask`
            case full
            
            /// Name only: `marsanne`
            case nameOnly
        }
        
        /// Whether the repo is first-party (`homebrew/[name]`) or third-party (`[anything]/[anything]`)
        public enum BrewRepo: Hashable, Equatable, Sendable
        {
            /// First-party repo, resolves to `homebrew`
            case homebrew
            /// Third-party repo, resolves to whatever `name` is
            case external(name: String)
            
            var name: String
            {
                switch self
                {
                case .homebrew:
                    return "homebrew"
                case .external(let name):
                    return name
                }
            }
        }
        
        let repoAddress: URL?
        let repo: BrewRepo
        let tapName: String
        
        /// Initialize a tap name from components
        public init(
            repoAddress: URL? = nil,
            repo: BrewRepo,
            tapName: String
        ) {
            self.repoAddress = repoAddress
            self.repo = repo
            self.tapName = tapName
        }
        
        /// Errors that can happen during tap name initialization from ``String``
        public enum BrewTapNameInitializationError: LocalizedError
        {
            /// The provided name didn't have exactly one slash
            case wrongNumberOfSlashes
            
            /// The splitting along the slash didn't produce two results
            case invalidFormat
        }
        
        /// Initialize a tap name from its string representation (`marsanne/cask`), with an optional external repository
        public init(
            repoAddress: URL? = nil,
            tapNameString: String,
        ) throws(BrewTapNameInitializationError) {
            
            /// Tap name with unexpected characters removed (whitespace and any extra slashes surrounding the name)
            let sanitizedTapString: String = tapNameString
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .init(charactersIn: "/"))
            
            let splitTapString = sanitizedTapString.components(separatedBy: "/")
            
            guard splitTapString.count == 2 else
            {
                throw .wrongNumberOfSlashes
            }
            
            if let repoName = splitTapString.first, let tapName = splitTapString.last
            {
                self.repoAddress = repoAddress
                
                if repoName == "homebrew"
                {
                    self.repo = .homebrew
                }
                else
                {
                    self.repo = .external(name: repoName)
                }
                
                self.tapName = tapName
            }
            else
            {
                throw .invalidFormat
            }
        }
    }
    
    /// Initialize the tap from a name string, along with an optional external repo
    public init(
        externalRepo: URL? = nil,
        name: String
    ) throws(BrewTapName.BrewTapNameInitializationError) {
        self.nameInternal = try .init(repoAddress: externalRepo, tapNameString: name)
        
        self.isBeingModified = false
    }
    
    /// Initialize the tap with a chunked name
    public init(
        name: BrewTapName
    ) {
        self.nameInternal = name
        
        self.isBeingModified = false
    }
    
    public let id: UUID = .init()
    
    private let nameInternal: BrewTapName
    
    public func name(
        withPrecision precision: BrewTapName.NameRetrievalPrecision
    ) -> String
    {
        if let externalAddress = self.nameInternal.repoAddress
        {
            switch precision
            {
            case .full:
                return "\(externalAddress)/\(self.nameInternal.repo.name)/\(self.nameInternal.tapName)"
            case .nameOnly:
                return self.nameInternal.tapName
            }
        }
        else
        {
            switch precision {
            case .full:
                return "\(self.nameInternal.repo.name)/\(self.nameInternal.tapName)"
            case .nameOnly:
                return self.nameInternal.tapName
            }
        }
        
    }
    
    public func getCopleteTapName() -> BrewTapName
    {
        return self.nameInternal
    }

    public var isBeingModified: Bool

    public func changeBeingModifiedStatus()
    {
        isBeingModified.toggle()
    }
    
    // MARK: - Fonformance functions
    
    public nonisolated static func == (
        lhs: BrewTap,
        rhs: BrewTap
    ) -> Bool {
        return lhs.getCopleteTapName() == rhs.getCopleteTapName()
    }
    
    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(self.getCopleteTapName())
    }
}

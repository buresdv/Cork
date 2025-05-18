//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import AppKit
import DavidFoundation
import Foundation
import CorkShared
import SwiftData

/// A representation of a Homebrew package
struct BrewPackage: Identifiable, Equatable, Hashable, Codable
{
    var id: UUID = .init()
    let name: String

    lazy var sanitizedName: String? = {
        var packageNameWithoutTap: String
        { /// First, remove the tap name from the package name if it has it
            if self.name.contains("/")
            { /// Check if the package name contains slashes (this would mean it includes the tap name)
                if let sanitizedName = try? self.name.regexMatch("[^\\/]*$")
                {
                    return sanitizedName
                }
                else
                {
                    return self.name
                }
            }
            else
            {
                return self.name
            }
        }

        if packageNameWithoutTap.contains("@")
        { /// Only do the matching if the name contains @
            if let sanitizedName = try? packageNameWithoutTap.regexMatch(".+?(?=@)")
            { /// Try to REGEX-match the name out of the raw name
                return sanitizedName
            }
            else
            { /// If the REGEX matching fails, just show the entire name
                return packageNameWithoutTap
            }
        }
        else
        { /// If the name doesn't contain the @, don't do anything
            return packageNameWithoutTap
        }
    }()

    let type: PackageType
    var isTagged: Bool = false

    let installedOn: Date?
    let versions: [String]

    var installedIntentionally: Bool = true

    let sizeInBytes: Int64?
    
    /// Download count for top packages
    let downloadCount: Int?

    var isBeingModified: Bool = false

    func getFormattedVersions() -> String
    {
        return versions.formatted(.list(type: .and))
    }
    
    /// The purpose of the tagged status change operation
    enum TaggedStatusChangePurpose: String
    {
        /// Only load and apply the tagged status to packages
        ///
        /// For when the tagged packages are just being loaded and applied to the packages
        case justLoading = "loading"
        
        /// Change and persist the change.
        ///
        /// For when the user initiates the change.
        case actuallyChangingTheTaggedState = "actually changing the tagged state"
    }
    
    /// Change the tagged status of a package, and optionally persist that change in the database
    ///
    /// - Parameter purpose: The purpose of this operation
    @MainActor
    mutating func changeTaggedStatus(purpose: TaggedStatusChangePurpose)
    {
        
        let packageName: String = self.name
        
        AppConstants.shared.logger.debug("Will change the tagged status of package \(packageName) for the purpose of \(purpose.rawValue)")
        
        if purpose == .actuallyChangingTheTaggedState
        {            
            let modelContext: ModelContext = AppConstants.shared.modelContainer.mainContext
            
            if !isTagged
            {
                modelContext.insert(SavedTaggedPackage(fullName: self.name))
            }
            else
            {
                modelContext.delete(SavedTaggedPackage(fullName: self.name))
            }
        }
        
        isTagged.toggle()
    }

    mutating func changeBeingModifiedStatus()
    {
        isBeingModified.toggle()
    }

    mutating func purgeSanitizedName()
    {
        sanitizedName = nil
    }

    /// Open the location of this package in Finder
    func revealInFinder() throws
    {
        enum FinderRevealError: LocalizedError
        {
            case couldNotFindPackageInParent

            var errorDescription: String?
            {
                return String(localized: "error.finder-reveal.could-not-find-package-in-parent")
            }
        }

        var packageURL: URL?
        var packageLocationParent: URL
        {
            if type == .formula
            {
                return AppConstants.shared.brewCellarPath
            }
            else
            {
                return AppConstants.shared.brewCaskPath
            }
        }

        do
        {
            let contentsOfParentFolder: [URL] = try FileManager.default.contentsOfDirectory(at: packageLocationParent, includingPropertiesForKeys: [.isDirectoryKey])
            
            packageURL = contentsOfParentFolder.filter
            {
                $0.lastPathComponent.contains(name)
            }.first
            
            guard let packageURL
            else
            {
                throw FinderRevealError.couldNotFindPackageInParent
            }
            
            packageURL.revealInFinder(.openParentDirectoryAndHighlightTarget)
        }
        catch let finderRevealError
        {
            AppConstants.shared.logger.error("Failed while revealing package: \(finderRevealError.localizedDescription)")
            /// Play the error sound
            NSSound(named: "ping")?.play()
        }
    }
}

extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}

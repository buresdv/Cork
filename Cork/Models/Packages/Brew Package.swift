//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import AppKit
import CorkShared
import DavidFoundation
import Foundation
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
    
    var isPinned: Bool = false

    let installedOn: Date?
    let versions: [String]

    let url: URL?
    
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
            let saveablePackageRepresentation: SavedTaggedPackage = .init(fullName: packageName)
            
            if !isTagged
            {
                AppConstants.shared.logger.debug("Will add package representation \(saveablePackageRepresentation.fullName) to the persistence container")
                
                saveablePackageRepresentation.saveSelfToDatabase()
            }
            else
            {
                AppConstants.shared.logger.debug("Will remove package \(saveablePackageRepresentation.fullName) from the persistence container")
                
                saveablePackageRepresentation.deleteSelfFromDatabase()
            }
        }
        
        isTagged.toggle()
    }

    enum PinnedStatus
    {
        case pinned
        case unpinned
    }
    
    /// Toggle pinned status of the package.
    ///
    /// Optionally specify which status to change the package to.
    ///
    /// This function only changes the pinned status in the UI. Use the function ``performPinnedStatusChangeAction(appState:brewPackagesTracker:)`` to trigger a pinned status change in Homebrew.
    mutating func changePinnedStatus(to status: PinnedStatus? = nil)
    {
        if let status
        {
            switch status {
            case .pinned:
                isPinned = true
            case .unpinned:
                isPinned = false
            }
        }
        else
        {
            isPinned.toggle()
        }
    }
    
    /// Perform a pinned status change in Homebrew.
    ///
    /// For changing the pinned status of the package in the UI, use the function ``changePinnedStatus(to:)``
    func performPinnedStatusChangeAction(appState: AppState, brewPackagesTracker: BrewPackagesTracker) async
    {
        /// We need to get the number of packages that were pinned before the action, because if there's only one and it gets unpinned, the whole folder with pinned packages is deleted - therefore, there would be a bug where unpinning the last package would make it seem like the whole process failed
        async let numberOfPinnedPackagesBeforePinChangeAction: Int = await brewPackagesTracker.successfullyLoadedFormulae.filter { $0.isPinned }.count
        
        if self.isPinned
        {
            let pinResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["unpin", name])

            if !pinResult.standardError.isEmpty
            {
                AppConstants.shared.logger.error("Error pinning: \(pinResult.standardError, privacy: .public)")
            }
        }
        else
        {
            let unpinResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["pin", name])
            if !unpinResult.standardError.isEmpty
            {
                AppConstants.shared.logger.error("Error unpinning: \(unpinResult.standardError, privacy: .public)")
            }
        }

        guard let pinnedPackagesPath: URL = AppConstants.shared.pinnedPackagesPath else
        {
            /// If there was only pinned package left, it got correctly unpinned, but then the folder was deleted, so this `guard` got tripped and made it seem like the proces failed, because the whole folder gets deleted after the last package gets unpinned
            /// Therefore, in this case, we just say that there are no packages left to be pinned
            /// We also have to capture this variable
            let numberOfPinnedPackagesBeforePinChangeAction: Int = await numberOfPinnedPackagesBeforePinChangeAction
            
            AppConstants.shared.logger.debug("Tripped condition for the pinned packages missing. Number of pinned packages before the pin change action: \(numberOfPinnedPackagesBeforePinChangeAction)")
            
            if numberOfPinnedPackagesBeforePinChangeAction == 1
            {
                await brewPackagesTracker.applyPinnedStatus(namesOfPinnedPackages: .init())
                
                return
            }
            else
            {
                await appState.showAlert(errorToShow: .couldNotAssociateAnyPackageWithProvidedPackageUUID)
                
                return
            }
        }
                
        await brewPackagesTracker.applyPinnedStatus(namesOfPinnedPackages: brewPackagesTracker.getNamesOfPinnedPackages(atPinnedPackagesPath: pinnedPackagesPath))
    }
    
    mutating func changeBeingModifiedStatus(to setState: Bool? = nil)
    {
        let packageName: String = self.name
        
        AppConstants.shared.logger.debug("Will change the \"Being Modified\" status of package \(packageName)")
        
        if let setState
        {
            self.isBeingModified = setState
        }
        else
        {
            isBeingModified.toggle()
        }
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

/// Convert between ``MinimalHomebrewPackage`` and ``BrewPackage``
extension BrewPackage
{
    init?(from minimalPackage: MinimalHomebrewPackage?)
    {
        guard let minimalPackage = minimalPackage else { return nil }

        self.init(
            name: minimalPackage.name,
            type: minimalPackage.type,
            installedOn: minimalPackage.installDate,
            versions: [],
            url: nil,
            sizeInBytes: nil,
            downloadCount: nil
        )
    }
}

extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}

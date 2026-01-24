//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import AppKit
import CorkShared
import DavidFoundation
import Foundation
import SwiftData
import Charts
import AppIntents
import SwiftUI
import CorkTerminalFunctions

/// A representation of the loaded ``BrewPackage``s
/// Includes packages that were loaded properly, along those whose loading failed
public typealias BrewPackages = Set<Result<BrewPackage, BrewPackage.PackageLoadingError>>

/// A representation of a Homebrew package
public struct BrewPackage: Identifiable, Equatable, Hashable, Codable, Sendable, Modifiable
{
    /// The package's name parsed into chunks
    public struct BrewPackageName: Equatable, Hashable, Codable, Sendable
    {
        
        public init(from unparsedName: String)
        {
            let packageNameWithoutTap: String =
            { /// First, remove the tap name from the package name if it has it
                
                /// If there are no slashes, return the package name, as we don't need to modify the slashes
                guard unparsedName.contains("/") else
                {
                    return unparsedName
                }
                
                if let sanitizedName = try? unparsedName.regexMatch("[^\\/]*$")
                { /// Try to remove everything before the last slash
                    return sanitizedName
                }
                else
                { /// If the removal of the slashes doesn't work, return the unmodified name
                    return unparsedName
                }
            }()
            
            /// If there is no `@` - meaning there is no bound version - just init with the name without the tap slashes
            guard packageNameWithoutTap.contains("@") else
            {
                self.packageIdentifier = unparsedName
                self.boundVersion = nil
                
                return
            }
            
            let splitPackageName: [String] = packageNameWithoutTap.components(separatedBy: "@")
            
            /// Check if there are actually only two components to the name - if not, something went wrong, and we return the unparsed name
            guard splitPackageName.count == 2 else
            {
                AppConstants.shared.logger.error("Failed while parsing package name \(packageNameWithoutTap, privacy: .public). Name should not contain more than two components at this stage.")
                
                self.packageIdentifier = packageNameWithoutTap
                self.boundVersion = nil
                
                return
            }
            
            if let packageIdentifier = splitPackageName.first, let boundVersion = splitPackageName.last
            {
                self.packageIdentifier = packageIdentifier
                self.boundVersion = boundVersion
            } else {
                AppConstants.shared.logger.error("Failed while parsing package name \(packageNameWithoutTap, privacy: .public). There should be at least two elements in the split version at this stage.")
                
                self.packageIdentifier = packageNameWithoutTap
                self.boundVersion = nil
            }
        }
        
        /// The core name of the package
        ///
        /// If the package has a bound version, this is the part before the `@`.  In the case of `cork@beta`, the Package Identifier is `cork`
        public let packageIdentifier: String
        
        /// The bound version of the package, designating its specific version or release
        ///
        /// If the package has a bound version, this is the part after the `@`. In the case of `cork@beta`, the Bound Version is `beta`
        public let boundVersion: String?
    }
    
    public init(
        name: String,
        type: BrewPackage.PackageType,
        isTagged: Bool? = nil,
        isPinned: Bool? = nil,
        installedOn: Date?,
        versions: [String],
        url: URL?,
        installedIntentionally: Bool? = nil,
        sizeInBytes: Int64?,
        downloadCount: Int?
    ) {
        self.id = .init()
        self.name = .init(from: name)
        self.type = type
        self.isTagged = isTagged ?? false
        self.isPinned = isPinned ?? false
        self.installedOn = installedOn
        self.versions = versions
        self.url = url
        self.installedIntentionally = self.type == .cask ? true : installedIntentionally ?? false // If the package is cask, it was installed intentionally. If it's a formula, check if an override was provided, and if not, set it to false
        self.sizeInBytes = sizeInBytes
        self.downloadCount = downloadCount
        self.isBeingModified = false
    }
    
    public var id: UUID
    private let name: BrewPackageName

    public let type: PackageType
    public var isTagged: Bool = false
    
    public var isPinned: Bool

    public let installedOn: Date?
    public let versions: [String]

    public let url: URL?
    
    public var installedIntentionally: Bool

    public let sizeInBytes: Int64?

    /// Download count for top packages
    public let downloadCount: Int?

    public var isBeingModified: Bool = false

    public func getFormattedVersions() -> String
    {
        return versions.formatted(.list(type: .and))
    }
    
    public enum PackageType: String, CustomStringConvertible, Plottable, AppEntity, Codable
    {
        case formula
        case cask

        /// User-readable description of the package type
        public var description: String
        {
            switch self
            {
            case .formula:
                return String(localized: "package-details.type.formula")
            case .cask:
                return String(localized: "package-details.type.cask")
            }
        }

        /// Localization keys for description of the package type
        public var localizableDescription: LocalizedStringKey
        {
            switch self
            {
            case .formula:
                return "package-details.type.formula"
            case .cask:
                return "package-details.type.cask"
            }
        }

        /// Parent folder for this package type
        public var parentFolder: URL
        {
            switch self
            {
            case .formula:
                return AppConstants.shared.brewCellarPath
            case .cask:
                return AppConstants.shared.brewCaskPath
            }
        }

        /// Accessibility representation
        public var accessibilityLabel: LocalizedStringKey
        {
            switch self
            {
            case .formula:
                return "accessibility.label.package-type.formula"
            case .cask:
                return "accessibility.label.package-type.cask"
            }
        }

        public static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "package-details.type")

        public var displayRepresentation: DisplayRepresentation
        {
            switch self
            {
            case .formula:
                DisplayRepresentation(title: "package-details.type.formula")
            case .cask:
                DisplayRepresentation(title: "package-details.type.cask")
            }
        }
    }
    
    // MARK: - Logic
    /// How precise the retrieved name should be - if it's about the package in general, or the very specific version of that package
    public enum NameRetrievalPrecision
    {
        /// Includes only the base name
        case general
        
        /// Includes the base name and the bound version, if one exists
        case precise
    }
    
    /// Get a formatted version of the package's name
    public func getPackageName(withPrecision precision: NameRetrievalPrecision) -> String
    {
        switch precision
        {
        case .general:
            return self.name.packageIdentifier
        case .precise:
            guard let boundVersionUnwrapped = name.boundVersion else
            {
                return self.name.packageIdentifier
            }
            
            return "\(self.name.packageIdentifier)@\(boundVersionUnwrapped)"
        }
    }
    
    /// Get the whole package name struct
    public func getCompletePackageName() -> BrewPackageName
    {
        return self.name
    }
    
    /// The purpose of the tagged status change operation
    public enum TaggedStatusChangePurpose: String
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
    public mutating func changeTaggedStatus(purpose: TaggedStatusChangePurpose)
    {
        
        let packageName: String = self.getPackageName(withPrecision: .precise)
        
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

    public enum PinnedStatus
    {
        case pinned
        case unpinned
    }
    
    /// Toggle pinned status of the package.
    ///
    /// Optionally specify which status to change the package to.
    ///
    /// This function only changes the pinned status in the UI. Use the function ``performPinnedStatusChangeAction(appState:brewPackagesTracker:)`` to trigger a pinned status change in Homebrew.
    public mutating func changePinnedStatus(to status: PinnedStatus? = nil)
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
    public func performPinnedStatusChangeAction(appState: AppState, brewPackagesTracker: BrewPackagesTracker) async
    {
        /// We need to get the number of packages that were pinned before the action, because if there's only one and it gets unpinned, the whole folder with pinned packages is deleted - therefore, there would be a bug where unpinning the last package would make it seem like the whole process failed
        async let numberOfPinnedPackagesBeforePinChangeAction: Int = await brewPackagesTracker.successfullyLoadedFormulae.filter { $0.isPinned }.count
        
        if self.isPinned
        {
            let pinResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["unpin", self.getPackageName(withPrecision: .precise)])

            if !pinResult.standardError.isEmpty
            {
                AppConstants.shared.logger.error("Error pinning: \(pinResult.standardError, privacy: .public)")
            }
        }
        else
        {
            let unpinResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["pin", self.getPackageName(withPrecision: .precise)])
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
    
    public mutating func changeBeingModifiedStatus(to setState: Bool? = nil)
    {
        let packageName: String = self.getPackageName(withPrecision: .precise)
        
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

    /// Open the location of this package in Finder
    public func revealInFinder() throws
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
                $0.lastPathComponent.contains(self.getPackageName(withPrecision: .precise))
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
public extension BrewPackage
{
    init?(using minimalPackage: MinimalHomebrewPackage?)
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

public extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}


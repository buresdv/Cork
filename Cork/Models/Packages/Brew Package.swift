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
    var versions: [String]
    
    /// This is an internal Homebrew version for limiting package updates. Use this to compare installed versions with those in the tracker
    /// # Discussion
    /// For example, a package called `python@3` is limited to versions that begin with `3`. However, the package installed as `python@3` might actually have an installed version of `python@3.14`.
    ///
    /// If we just compare installed versions, `python@3` would not be considered the same package as `python@3.14`, despite them coming from the same `python@3` formula.
    ///
    /// Therefore, we need to separate the above `[String]` `versions` parameter from this one
    var homebrewVersion: String?

    var installedIntentionally: Bool = true

    let sizeInBytes: Int64?
    
    /// Download count for top packages
    let downloadCount: Int?

    var isBeingModified: Bool = false

    mutating func setHomebrewVersion(to version: String)
    {
        homebrewVersion = version
    }
    
    mutating func changeTaggedStatus()
    {
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

extension String
{
    
    /// Separate a package's name from its Homebrew version
    /// - Returns: Tuple containig the package's name, along with its Homebrew version
    func splitPackageNameFromHomebrewVersion() -> (packageName: String, homebrewVersion: String?)
    {
        guard self.contains("@") else
        {
            AppConstants.shared.logger.warning("Package \(self, privacy: .public) doesn't include version annotation. Will not split its name.")
            
            return (self, nil)
        }
        
        AppConstants.shared.logger.info("Package \(self, privacy: .public) has a version annotation. Will split its name from its Homebrew version")
        
        let splitPackageName: [String] = self.components(separatedBy: "@")
        
        let packageNameWithoutItsVersion: String = splitPackageName[0]
        let packageVersionWithoutItsName: String = splitPackageName[1]
        
        return (packageNameWithoutItsVersion, packageVersionWithoutItsName)
    }
}

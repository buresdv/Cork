//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import AppKit

struct BrewPackage: Identifiable, Equatable, Hashable
{
    var id = UUID()
    let name: String
    
    lazy var sanitizedName: String? =
    {
        var packageNameWithoutTap: String
        { /// First, remove the tap name from the package name if it has it
            if self.name.contains("/")
            { /// Check if the package name contains slashes (this would mean it includes the tap name)
                if let sanitizedName = try? regexMatch(from: self.name, regex: "[^\\/]*$")
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
            if let sanitizedName = try? regexMatch(from: packageNameWithoutTap, regex: ".+?(?=@)")
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
    
    let isCask: Bool
    var isTagged: Bool = false
    
    let installedOn: Date?
    let versions: [String]
    
    var installedIntentionally: Bool = true
    
    let sizeInBytes: Int64?
    
    var isBeingModified: Bool = false
    
    mutating func changeTaggedStatus() -> Void
    {
        self.isTagged.toggle()
    }
    
    mutating func changeBeingModifiedStatus() -> Void
    {
        self.isBeingModified.toggle()
    }
    
    mutating func purgeSanitizedName() -> Void
    {
        self.sanitizedName = nil
    }
    
    /// Open the location of this package in Finder
    func revealInFinder() throws
    {
        
        enum FinderRevealError: Error
        {
            case couldNotFindPackageInParent
        }
        
        var packageURL: URL?
        var packageLocationParent: URL
        {
            if !isCask
            {
                return AppConstants.brewCellarPath
            }
            else
            {
                return AppConstants.brewCaskPath
            }
        }
        
        let contentsOfParentFolder = try! FileManager.default.contentsOfDirectory(at: packageLocationParent, includingPropertiesForKeys: [.isDirectoryKey])
        
        packageURL = contentsOfParentFolder.filter({ $0.lastPathComponent.contains(name) }).first
        
        guard let packageURL else
        {
            throw FinderRevealError.couldNotFindPackageInParent
        }
        
        packageURL.revealInFinder(.openParentDirectoryAndHighlightTarget)
        
        //NSWorkspace.shared.selectFile(packageURL.path, inFileViewerRootedAtPath: packageURL.deletingLastPathComponent().path)
    }
}

extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        Self.dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}

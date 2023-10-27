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
        
        NSWorkspace.shared.selectFile(packageURL.path, inFileViewerRootedAtPath: packageURL.deletingLastPathComponent().path)
    }
}

extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        Self.dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}

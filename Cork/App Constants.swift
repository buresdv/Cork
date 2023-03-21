//
//  App Constants.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftyJSON

struct AppConstants {
    /// **Basic executables and file locations**
    static let brewExecutablePath: URL =
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/bin/brew")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/bin/brew")!
        }
    }()
    static let brewCellarPath: URL =
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Cellar")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/Cellar")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/Cellar")!
        }
    }()
    static let brewCaskPath: URL =
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Caskroom")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/Caskroom")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/Caskroom")!
        }
    }()
    static let tapPath: URL =
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Library/Taps")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/Library/Taps")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/Homebrew/Library/Taps")!
        }
    }()
    
    /// **Storage for tagging**
    static let documentsDirectoryPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Cork", conformingTo: .directory)
    static let metadataFilePath: URL = documentsDirectoryPath.appendingPathComponent("Metadata", conformingTo: .data)
    
    /// **Brew cache**
    static let brewCachePath: URL = URL(string: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)!.appendingPathComponent("Caches", conformingTo: .directory).appendingPathComponent("Homebrew", conformingTo: .directory) // /Users/david/Library/Caches/Homebrew
    
    /// These two have the symlinks to the actual downloads
    static let brewCachedFormulaeDownloadsPath: URL = brewCachePath
    static let brewCachedCasksDownloadsPath: URL = brewCachePath.appendingPathComponent("Cask", conformingTo: .directory)
    
    /// This one has all the downloaded files themselves
    static let brewCachedDownloadsPath: URL = brewCachePath.appendingPathComponent("downloads", conformingTo: .directory)
}

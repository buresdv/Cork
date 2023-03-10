//
//  App Constants.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftyJSON

struct AppConstants {
    static var brewExecutablePath: URL
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/bin/brew")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/bin/brew")!
        }
    }
    static var brewCellarPath: URL
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Cellar")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/Cellar")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/Cellar")!
        }
    }
    static var brewCaskPath: URL
    {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Caskroom")
        { // Apple Sillicon
            return URL(string: "/opt/homebrew/Caskroom")!
        }
        else
        { // Intel
            return URL(string: "/usr/local/Caskroom")!
        }
    }
    
    static let brewCachePath: URL = URL(string: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)!.appendingPathComponent("Caches", conformingTo: .directory).appendingPathComponent("Homebrew", conformingTo: .directory) // /Users/david/Library/Caches/Homebrew
    
    /// These two have the symlinks to the actual downloads
    static let brewCachedFormulaeDownloadsPath: URL = brewCachePath
    static let brewCachedCasksDownloadsPath: URL = brewCachePath.appendingPathComponent("Cask", conformingTo: .directory)
    
    /// This one has all the downloaded files themselves
    static let brewCachedDownloadsPath: URL = brewCachePath.appendingPathComponent("downloads", conformingTo: .directory)
}

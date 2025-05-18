//
//  App Constants.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import OSLog
import SwiftData
@preconcurrency import UserNotifications

public struct AppConstants: Sendable
{
    
    // MARK: - Initializer
    init()
    {
        
        let internalLogger: Logger = .init(subsystem: "com.davidbures.cork", category: "Cork")
        
        // MARK: - Initialize proxy settings
        self.proxySettings = {
            let proxySettings: [String: Any]? = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as? [String: Any]
            
            guard let httpProxyHost = proxySettings?[kCFNetworkProxiesHTTPProxy as String] as? String
            else
            {
                internalLogger.error("Could not get proxy host")
                
                return nil
            }
            guard let httpProxyPort = proxySettings?[kCFNetworkProxiesHTTPPort as String] as? Int
            else
            {
                internalLogger.error("Could not get proxy port")
                
                return nil
            }
            
            return (host: httpProxyHost, port: httpProxyPort)
        }()
        
        // MARK: -
        self.documentsDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "Cork", directoryHint: .isDirectory)
        
        self.metadataFilePath = self.documentsDirectoryPath.appending(component: "Metadata", directoryHint: .notDirectory).appendingPathExtension("brewmeta")
        
        self.brewCachePath = URL.libraryDirectory.appending(component: "Caches", directoryHint: .isDirectory).appending(component: "Homebrew", directoryHint: .isDirectory)
        
        self.brewCachedFormulaeDownloadsPath = brewCachePath
        
        self.brewCachedCasksDownloadsPath = brewCachePath.appending(component: "Cask", directoryHint: .isDirectory)
        
        self.brewCachedDownloadsPath = brewCachePath.appending(component: "downloads", directoryHint: .isDirectory)
        
        let localHomebrewVariablesPath: URL = {
            if FileManager.default.fileExists(atPath: "/opt/homebrew/var/homebrew")
            { // Apple Sillion
                return URL(filePath: "/opt/homebrew/var/homebrew")
            }
            else
            { // Intel
                return URL(filePath: "/usr/local/var/homebrew")
            }
        }()
        
        self.homebrewVariablesPath = localHomebrewVariablesPath
        
        self.logger = internalLogger
        
        let modelConfiguration: ModelConfiguration = .init(isStoredInMemoryOnly: false)
        
        guard let initializedModelContainer = try? ModelContainer(for: SavedTaggedPackage.self, configurations: modelConfiguration) else
        {
            fatalError("Failed to initialize persistence container")
        }
        
        self.modelContainer = initializedModelContainer
    }
    
    // MARK: - Shared Instance
    
    public static let shared: AppConstants = .init()
    
    // MARK: - Persistence
    public let modelContainer: ModelContainer
    
    // MARK: - Logging

    public let logger: Logger

    // MARK: - Notification stuff

    public let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    // MARK: - Proxy settings

    public let proxySettings: (host: String, port: Int)?

    // MARK: - Basic executables and file locations
    
    public let brewExecutablePath: URL = {
        /// If a custom Homebrew path is defined, use it. Otherwise, use the default paths
        if let homebrewPath = UserDefaults.standard.string(forKey: "customHomebrewPath"), !homebrewPath.isEmpty
        {
            let customHomebrewPath: URL = .init(string: homebrewPath)!

            return customHomebrewPath
        }
        else
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
    }()

    public let brewCellarPath: URL = {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Cellar")
        { // Apple Sillicon
            return URL(filePath: "/opt/homebrew/Cellar")
        }
        else
        { // Intel
            return URL(filePath: "/usr/local/Cellar")
        }
    }()

    public let brewCaskPath: URL = {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Caskroom")
        { // Apple Sillicon
            return URL(filePath: "/opt/homebrew/Caskroom")
        }
        else
        { // Intel
            return URL(filePath: "/usr/local/Caskroom")
        }
    }()

    public let tapPath: URL = {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Library/Taps")
        { // Apple Sillicon
            return URL(filePath: "/opt/homebrew/Library/Taps")
        }
        else
        { // Intel
            return URL(filePath: "/usr/local/Homebrew/Library/Taps")
        }
    }()
    
    public let homebrewVariablesPath: URL
    
    /// Folder that contains symlinks pinned packages
    ///
    /// If no package is pinned, this folder doesn't exist. However, if this is not a computed property, we can only know whether this folder exists at app start. Therefore, we need this property to be re-computed every time to make sure that the folder exists when we want to read whether a particular package is pinned, and not just whether it existed when we started the app.
    public var pinnedPackagesPath: URL? {
        let expectedPathToPinnedPackagesFolder: URL = self.homebrewVariablesPath.appending(component: "pinned")
        
        if FileManager.default.fileExists(atPath: expectedPathToPinnedPackagesFolder.path)
        {
            self.logger.debug("Recomputed the presence of pinned packages database folder with result: EXISTS")
            return expectedPathToPinnedPackagesFolder
        }
        else
        {
            self.logger.debug("Recomputed the presence of pinned packages database folder with result: DOES NOT EXIST")
            return nil
        }
    }

    // MARK: - Storage for tagging

    public let documentsDirectoryPath: URL
    public let metadataFilePath: URL

    // MARK: - Brew Cache

    /// Path to the cached downloads
    /// `/Users/david/Library/Caches/Homebrew`
    public let brewCachePath: URL

    /// Has symlinks to the cached downloads
    /// `/Users/david/Library/Caches/Homebrew`
    public let brewCachedFormulaeDownloadsPath: URL
    public let brewCachedCasksDownloadsPath: URL

    /// This one has all the downloaded files themselves
    public let brewCachedDownloadsPath: URL

    // MARK: - Licensing

    public let demoLengthInSeconds: Double = 604_800 // 7 days

    public let authorizationEndpointURL: URL = .init(string: "https://automation.tomoserver.eu/webhook/38aacca6-5da8-453c-a001-804b15751319")!
    public let licensingAuthorization: (username: String, passphrase: String) = ("cork-authorization", "choosy-defame-neon-resume-cahoots")

    // MARK: - Temporary OS version submission

    public let osSubmissionEndpointURL: URL = .init(string: "https://automation.tomoserver.eu/webhook/3a971576-fa96-479e-9dc4-e052fe33270b")!

    // MARK: - Misc Stuff

    public let backgroundUpdateInterval: TimeInterval = 10 * 60
    public let backgroundUpdateIntervalTolerance: TimeInterval = 1 * 60

    public let osVersionString: (lookupName: String, fullName: String) = {
        let versionDictionary: [Int: (lookupName: String, fullName: String)] = [
            15: ("sequoia", "Sequoia"),
            14: ("sonoma", "Sonoma"),
            13: ("ventura", "Ventura"),
            12: ("monterey", "Monterey"),
            11: ("big_sur", "Big Sur"),
            10: ("legacy", "Legacy")
        ]

        let macOSVersionTheUserIsRunning: Int = ProcessInfo.processInfo.operatingSystemVersion.majorVersion

        return versionDictionary[macOSVersionTheUserIsRunning, default: ("legacy", "Legacy")]
    }()
}

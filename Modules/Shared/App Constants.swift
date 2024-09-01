//
//  App Constants.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import OSLog
import UserNotifications

public struct AppConstants
{
    // MARK: - Logging

    public static let logger: Logger = .init(subsystem: "com.davidbures.cork", category: "Cork")

    // MARK: - Notification stuff

    public static let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    // MARK: - Proxy settings

    public static let proxySettings: (host: String, port: Int)? = {
        let proxySettings: [String: Any]? = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as? [String: Any]

        guard let httpProxyHost = proxySettings?[kCFNetworkProxiesHTTPProxy as String] as? String
        else
        {
            AppConstants.logger.error("Could not get proxy host")

            return nil
        }
        guard let httpProxyPort = proxySettings?[kCFNetworkProxiesHTTPPort as String] as? Int
        else
        {
            AppConstants.logger.error("Could not get proxy port")

            return nil
        }

        return (host: httpProxyHost, port: httpProxyPort)
    }()

    // MARK: - Basic executables and file locations

    public static let brewExecutablePath: URL = {
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

    public static let brewCellarPath: URL = {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Cellar")
        { // Apple Sillicon
            return URL(filePath: "/opt/homebrew/Cellar")
        }
        else
        { // Intel
            return URL(filePath: "/usr/local/Cellar")
        }
    }()

    public static let brewCaskPath: URL = {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Caskroom")
        { // Apple Sillicon
            return URL(filePath: "/opt/homebrew/Caskroom")
        }
        else
        { // Intel
            return URL(filePath: "/usr/local/Caskroom")
        }
    }()

    public static let tapPath: URL = {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/Library/Taps")
        { // Apple Sillicon
            return URL(filePath: "/opt/homebrew/Library/Taps")
        }
        else
        { // Intel
            return URL(filePath: "/usr/local/Homebrew/Library/Taps")
        }
    }()

    // MARK: - Storage for tagging

    public static let documentsDirectoryPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "Cork", directoryHint: .isDirectory)
    public static let metadataFilePath: URL = documentsDirectoryPath.appending(component: "Metadata", directoryHint: .notDirectory).appendingPathExtension("brewmeta")

    // MARK: - Brew Cache

    public static let brewCachePath: URL = URL.libraryDirectory.appending(component: "Caches", directoryHint: .isDirectory).appending(component: "Homerbew", directoryHint: .isDirectory) // /Users/david/Library/Caches/Homebrew

    /// These two have the symlinks to the actual downloads
    public static let brewCachedFormulaeDownloadsPath: URL = brewCachePath
    public static let brewCachedCasksDownloadsPath: URL = brewCachePath.appending(component: "Cask", directoryHint: .isDirectory)

    /// This one has all the downloaded files themselves
    public static let brewCachedDownloadsPath: URL = brewCachePath.appending(component: "downloads", directoryHint: .isDirectory)

    // MARK: - Licensing

    public static let demoLengthInSeconds: Double = 604_800 // 7 days

    public static let authorizationEndpointURL: URL = .init(string: "https://automation.tomoserver.eu/webhook/38aacca6-5da8-453c-a001-804b15751319")!
    public static let licensingAuthorization: (username: String, passphrase: String) = ("cork-authorization", "choosy-defame-neon-resume-cahoots")

    // MARK: - Temporary OS version submission

    public static let osSubmissionEndpointURL: URL = .init(string: "https://automation.tomoserver.eu/webhook/3a971576-fa96-479e-9dc4-e052fe33270b")!

    // MARK: - Misc Stuff

    public static let backgroundUpdateInterval: TimeInterval = 10 * 60
    public static let backgroundUpdateIntervalTolerance: TimeInterval = 1 * 60

    public static let osVersionString: (lookupName: String, fullName: String) = {
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

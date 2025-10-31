//
//  Check if Package was Installed Intentionally.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import CorkShared

public enum IntentionalInstallationDiscoveryError: Error, Hashable
{
    /// The function could not determine the most relevant version of the package to read the recepit from
    case failedToDetermineMostRelevantVersion(packageURL: URL)
    
    /// The installation receipt is there, but cannot be read due to permission issues
    case failedToReadInstallationRecepit(packageURL: URL)
    
    /// The installation receipt could be read, but not parsed
    case failedToParseInstallationReceipt(packageURL: URL)
    
    /// The installation receipt is missing completely
    case installationReceiptMissingCompletely(packageURL: URL)
    
    /// The provided `URL` has an unexpected form
    case unexpectedFolderName(packageURL: URL)
}

public extension URL
{
    /// This function checks whether the package was installed intentionally.
    /// - For Formulae, this info gets read from the install receipt
    /// - Casks are always instaled intentionally
    /// - Parameter versionURLs: All available versions for this package. Some packages have multiple versions installed at a time (for example, the package `xz` might have versions 1.2 and 1.3 installed at once)
    /// - Returns: Indication whether this package was installed intentionally or not
    func checkIfPackageWasInstalledIntentionally(versionURLs: [URL]) async throws(IntentionalInstallationDiscoveryError) -> Bool
    {
        
        // TODO: Convert this so it uses the most recent version instead of a random one
        guard let localPackagePath = versionURLs.first
        else
        {
            throw .failedToDetermineMostRelevantVersion(packageURL: self)
            
            // throw .failedWhileLoadingCertainPackage(lastPathComponent, self, failureReason: String(localized: "error.package-loading.could-not-load-version-to-check-from-available-versions"))
        }
        
        if path.contains("Cellar")
        {
            let localPackageInfoJSONPath: URL = localPackagePath.appendingPathComponent("INSTALL_RECEIPT.json", conformingTo: .json)
            if FileManager.default.fileExists(atPath: localPackageInfoJSONPath.path)
            {
                struct InstallRecepitParser: Codable
                {
                    let installedOnRequest: Bool
                }
                
                let decoder: JSONDecoder = {
                    let decoder: JSONDecoder = .init()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    return decoder
                }()
                
                do
                {
                    let installReceiptContents: Data = try .init(contentsOf: localPackageInfoJSONPath)
                    
                    do
                    {
                        return try decoder.decode(InstallRecepitParser.self, from: installReceiptContents).installedOnRequest
                    }
                    catch let installReceiptParsingError
                    {
                        AppConstants.shared.logger.error("Failed to decode install receipt for package \(self.lastPathComponent, privacy: .public) with error \(installReceiptParsingError.localizedDescription, privacy: .public)")
                        
                        throw IntentionalInstallationDiscoveryError.failedToParseInstallationReceipt(packageURL: self)
                        
                        // throw PackageLoadingError.failedWhileLoadingCertainPackage(self.lastPathComponent, self, failureReason: String(localized: "error.package-loading.could-not-decode-installa-receipt-\(installReceiptParsingError.localizedDescription)"))
                    }
                }
                catch let installReceiptLoadingError
                {
                    AppConstants.shared.logger.error("Failed to load contents of install receipt for package \(self.lastPathComponent, privacy: .public) with error \(installReceiptLoadingError.localizedDescription, privacy: .public)")
                    
                    throw .failedToReadInstallationRecepit(packageURL: self)
                    
                    // throw .failedWhileLoadingCertainPackage(self.lastPathComponent, self, failureReason: String(localized: "error.package-loading.could-not-convert-contents-of-install-receipt-to-data-\(installReceiptLoadingError.localizedDescription)"))
                }
            }
            else
            { /// There's no install receipt for this package - silently fail and return that the packagw was not installed intentionally
                
                AppConstants.shared.logger.error("There appears to be no install receipt for package \(localPackageInfoJSONPath.lastPathComponent, privacy: .public)")
                
                let shouldStrictlyCheckForHomebrewErrors: Bool = UserDefaults.standard.bool(forKey: "strictlyCheckForHomebrewErrors")
                
                if shouldStrictlyCheckForHomebrewErrors
                {
                    throw .installationReceiptMissingCompletely(packageURL: self)
                    
                    // throw .failedWhileLoadingCertainPackage(lastPathComponent, self, failureReason: String(localized: "error.package-loading.missing-install-receipt"))
                }
                else
                {
                    return false
                }
            }
        }
        else if path.contains("Caskroom")
        {
            return true
        }
        else
        {
            throw .unexpectedFolderName(packageURL: self)
            // throw .failedWhileLoadingCertainPackage(lastPathComponent, self, failureReason: String(localized: "error.package-loading.unexpected-folder-name"))
        }
    }
}

//
//  Downgrading Sheet Contents.swift
//  Cork
//
//  Created by David Bureš - P on 10.10.2026.
//

import SwiftUI
import FactoryKit
import ApplicationInspector
import CorkShared
import ButtonKit
import CorkModels

struct DownloadingSheetContents: View
{
    @InjectedObservable(\.appState) var appState: AppState
    
    @Environment(DowngradeCorkView.DowngradeState.self) var downgradeState: DowngradeCorkView.DowngradeState

    private let downloader: Downloader = .init()

    let versionToDowngradeTo: DowngradeCorkView.CorkVersion

    enum DownloadingState
    {
        case downloading
        case downloaded(finalApplication: Application)
        case failed(error: Error)
    }

    @State private var downloadingState: DownloadingState = .downloading

    var body: some View
    {
        NavigationStack
        {
            sheetContents
            .padding()
            .toolbar {
                switch downloadingState {
                case .downloading:
                    ToolbarItem(placement: .cancellationAction)
                    {
                        AsyncButton
                        {
                            await downloader.cancel()
                        } label: {
                            Text("action.cancel")
                        }
                    }
                case .downloaded(let finalApplication):
                    ToolbarItem(placement: .primaryAction)
                    {
                        Button
                        {
                            downgradeState.sheetToShow = nil
                        } label: {
                            Text("add-package.install.finished")
                        }
                    }
                case .failed(let error):
                    ToolbarItem(placement: .primaryAction)
                    {
                        Button
                        {
                            downloadingState = .downloading
                        } label: {
                            Text("action.try-again")
                        }
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button
                        {
                            appState.dismissSheet()
                        } label: {
                            Text("action.select-another-version")
                        }

                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var sheetContents: some View
    {
        switch downloadingState
        {
        case .downloading:
            ProgressView("add-package.install.downloading-package-\(versionToDowngradeTo.versionName)")
                .task
                {
                    do
                    {
                        let finishedDownloadURL: URL = try await downloader.downloadFile(from: versionToDowngradeTo.assets.first(where: { $0.name == "Cork.zip" })!.browserDownloadUrl)

                        AppConstants.shared.logger.info("Finished download of old version and it's at this URL: \(finishedDownloadURL)")

                        let constructedFinalApp: Application = try await processDownloadedData(locationOnDisk: finishedDownloadURL)

                        downloadingState = .downloaded(finalApplication: constructedFinalApp)
                    }
                    catch is CancellationError
                    {
                        AppConstants.shared.logger.debug("Older Cork version downloading task cancelled")

                        downgradeState.sheetToShow = nil
                    }
                    catch let downloadingError
                    {
                        AppConstants.shared.logger.error("Failed while downloading Cork release: \(downloadingError)")

                        downloadingState = .failed(error: downloadingError)

                        return
                    }
                }
        case .downloaded(let finalApplication):
            DownloadFinishedView(finalApplication: finalApplication, versionToDowngradeTo: versionToDowngradeTo)
            
        case .failed(let error):
            if error is DownloadedDataProcessingError
            {
                switch error
                {
                case DownloadedDataProcessingError.couldNotParseApplication(let error, let urlForTheUserToGetTheAppThemselves):
                    Text(error.localizedDescription)

                    RevealInFinderButtonWithArbitraryAction
                    {
                        urlForTheUserToGetTheAppThemselves.revealInFinder(.openParentDirectoryAndHighlightTarget)
                    }

                default:
                    Text(error.localizedDescription)
                }
            }
            else
            {
                Text(error.localizedDescription)
            }
        }
    }
    
    private enum DownloadedDataProcessingError: LocalizedError
    {
        case couldNotUnzipTempArchive(error: Error)
        case couldNotParseApplication(error: Application.ApplicationInitializationError, urlForTheUserToGetTheAppThemselves: URL)

        var errorDescription: String?
        {
            switch self
            {
            case .couldNotUnzipTempArchive(let error):
                return String(localized: "downgrade-cork.error.could-not-unzip.\(error.localizedDescription)")
            case .couldNotParseApplication(let error, _):
                return String(localized: "downgrade-cork.error.could-not-construct-app.\(error.localizedDescription)")
            }
        }
    }

    private nonisolated func processDownloadedData(
        locationOnDisk: URL
    ) async throws(DownloadedDataProcessingError) -> Application
    {
        let fileManager: FileManager = .default

        let unzipTarget: URL = .temporaryDirectory.appendingPathComponent("Cork")

        AppConstants.shared.logger.info("Will check if we need to delete any old downloads.")

        if FileManager.default.fileExists(atPath: unzipTarget.path)
        {
            AppConstants.shared.logger.info("There is already an extracted executable at \(unzipTarget). Will try to remove it")

            try? FileManager.default.removeItem(at: unzipTarget)
        }

        do
        {
            AppConstants.shared.logger.info("Will unzip downloaded archive at \(locationOnDisk) to \(unzipTarget)")

            try fileManager.unzipItem(at: locationOnDisk, to: unzipTarget)

            AppConstants.shared.logger.info("Unzipped downloaded app to: \(unzipTarget)")
        }
        catch let archiveUnzippingError
        {
            AppConstants.shared.logger.error("Failed while unzipping the downloaded archive: \(archiveUnzippingError)")

            throw .couldNotUnzipTempArchive(error: archiveUnzippingError)
        }

        do
        {
            let corkAppInUnzipTarget: URL = unzipTarget.appendingPathComponent("Cork.app")

            AppConstants.shared.logger.info("Will try to initialize app from unzip target: \(unzipTarget). Will attach the Cork app fragment for a final URL: \(corkAppInUnzipTarget).")

            return try .init(from: corkAppInUnzipTarget)
        }
        catch let applicationConstructionError
        {
            AppConstants.shared.logger.error("Failed while constructing downloaded app: \(applicationConstructionError)")

            throw .couldNotParseApplication(error: applicationConstructionError, urlForTheUserToGetTheAppThemselves: unzipTarget)
        }
    }
}

private struct DownloadFinishedView: View {
    
    let finalApplication: Application
    let versionToDowngradeTo: DowngradeCorkView.CorkVersion
    
    var body: some View {
        VStack(alignment: .center, spacing: 10)
        {
            Text("downgrade-cork.success.title")
                .font(.title2)
                .multilineTextAlignment(.center)

            Text("downgrade-cork.instructions")

            VStack(alignment: .center, spacing: 5)
            {
                DraggableAppProxyIcon(app: finalApplication, width: 100)

                Text("\(finalApplication.name) - \(versionToDowngradeTo.versionName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

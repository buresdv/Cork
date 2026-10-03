//
//  Downgrade Cork View.swift
//  Cork
//
//  Created by David Bureš - P on 20.09.2026.
//

import ApplicationInspector
import ButtonKit
import CorkShared
import FactoryKit
import SwiftUI
import ZIPFoundation

struct DowngradeCorkView: View
{
    @Observable
    class DowngradeState
    {
        enum Sheets: Identifiable
        {
            var id: UUID
            {
                return .init()
            }

            case downloading(versionToDowngradeTo: CorkVersion)
        }

        var sheetToShow: Sheets?

        var isShowingSearchField: Bool = false
    }

    struct CorkVersion: Codable, Identifiable, Hashable
    {
        let id: UUID = .init()

        let versionName: String

        let githubPage: URL

        let releasedAt: Date

        let isPrerelease: Bool

        struct Assets: Codable, Hashable
        {
            let browserDownloadUrl: URL

            let name: String

            private enum CodingKeys: String, CodingKey
            {
                case browserDownloadUrl = "browser_download_url"
                case name
            }
        }

        let assets: [Assets]

        private enum CodingKeys: String, CodingKey
        {
            case versionName = "name"
            case githubPage = "html_url"
            case releasedAt = "published_at"
            case isPrerelease = "prerelease"
            case assets
        }
    }

    private enum PreviousReleasesFetchingError: LocalizedError
    {
        case failedToParse(error: String)
        case failedToDownload(DataDownloadingError)

        var errorDescription: String?
        {
            switch self
            {
            case .failedToDownload(let error):
                return error.errorDescription
            case .failedToParse(let error):
                return error
            }
        }
    }

    private enum AvailableVersionsDownloadingState
    {
        case loading(isReload: Bool)
        case loaded(versions: [CorkVersion])
        case failed(error: String)
    }

    @State private var availableVersionsLoadingState: AvailableVersionsDownloadingState = .loading(isReload: false)

    @State private var downgradeState: DowngradeState = .init()

    var body: some View
    {
        Group
        {
            switch availableVersionsLoadingState
            {
            case .loading(let isReload):
                ProgressView()
                    .task
                    {
                        do
                        {
                            let downloadedAvailableVersions: [CorkVersion] = try await listPreviousCorkVersions()

                            if isReload
                            {
                                AppConstants.shared.logger.debug("The action is reload - will sleep")
                                try await Task.sleep(for: .seconds(2))
                            }

                            self.availableVersionsLoadingState = .loaded(versions: downloadedAvailableVersions)
                        }
                        catch let availableVersionListingError
                        {
                            self.availableVersionsLoadingState = .failed(error: availableVersionListingError.localizedDescription)
                        }
                    }
            case .loaded(let versions):
                AvailableVersionsList(availableVersions: versions)
                    .sheet(item: Bindable(downgradeState).sheetToShow)
                    { sheetType in
                        switch sheetType
                        {
                        case .downloading(let versionToDowngradeTo):
                            DownloadingSheetContents(versionToDowngradeTo: versionToDowngradeTo)
                        }
                    }
                    .environment(downgradeState)
            case .failed(let error):
                ContentUnavailableView
                {
                    Label("downgrade-cork.listing-failed.title", image: "custom.arrow.down.app.badge.xmark")
                } description: {
                    Text(error)
                } actions: {
                    Button
                    {
                        self.availableVersionsLoadingState = .loading(isReload: true)
                    } label: {
                        Text("add-tap.error.action")
                    }
                }
            }
        }
        .frame(minWidth: 450, minHeight: 300)
    }

    private func listPreviousCorkVersions() async throws(PreviousReleasesFetchingError) -> [CorkVersion]
    {
        AppConstants.shared.logger.debug("Will fetch previous versions of Cork")

        let downloadedData: Data

        do
        {
            downloadedData = try await downloadDataFromURL(.init(string: "https://api.github.com/repos/buresdv/cork/releases")!, cachingPolicy: .reloadRevalidatingCacheData)
        }
        catch
        {
            AppConstants.shared.logger.error("Failed while downloading available versions: \(error)")
            throw .failedToDownload(error)
        }

        do
        {
            let decoder: JSONDecoder = {
                let decoder: JSONDecoder = .init()
                decoder.dateDecodingStrategy = .iso8601

                return decoder
            }()
            return try decoder.decode([CorkVersion].self, from: downloadedData).filter { !$0.isPrerelease }
        }
        catch
        {
            AppConstants.shared.logger.error("Failed while parsing available version: \(error)")
            throw .failedToParse(error: String(describing: error))
        }
    }
}

private struct AvailableVersionsList: View
{
    @LazyInjected(\.appConstants) var appConstants

    @Environment(DowngradeCorkView.DowngradeState.self) var downgradeState

    let availableVersions: [DowngradeCorkView.CorkVersion]

    @State private var selectedVersionToDowngradeToID: DowngradeCorkView.CorkVersion.ID?

    @State private var searchText: String = ""

    var displayedAvailableSections: [DowngradeCorkView.CorkVersion]
    {
        guard !self.searchText.isEmpty
        else
        {
            return .init(availableVersions)
        }

        return availableVersions.filter { $0.versionName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View
    {
        List(selection: $selectedVersionToDowngradeToID)
        {
            ForEach(displayedAvailableSections)
            { version in
                VersionListRow(availableVersion: version)
            }
        }
        .listStyle(.bordered)
        .alternatingRowBackgrounds(.enabled)
        .safeAreaInset(edge: .bottom, alignment: .trailing)
        {
            HStack(alignment: .center, spacing: 10)
            {
                AsyncButton
                {
                    if let selectedVersionToDowngradeToID, let selectedVersionToDowngradeTo = availableVersions.first(where: { $0.id == selectedVersionToDowngradeToID }), let corkZipDownloadURL = selectedVersionToDowngradeTo.assets.first(where: { $0.name == "Cork.zip" })
                    {
                        print("Would download release \(selectedVersionToDowngradeTo.versionName), URL: \(corkZipDownloadURL)")

                        downgradeState.sheetToShow = .downloading(versionToDowngradeTo: selectedVersionToDowngradeTo)
                    }
                } label: {
                    Text("action.download")
                }
                .disabled(selectedVersionToDowngradeToID == nil)
                .padding()
                .keyboardShortcut(.defaultAction)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            .background
            {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()
            }
        }
        .searchable(
            text: $searchText,
            isPresented: Bindable(downgradeState).isShowingSearchField,
            placement: .automatic,
            prompt: Text("downgrade-cork.search.prompt")
        )
    }
}

private struct VersionListRow: View
{
    let availableVersion: DowngradeCorkView.CorkVersion

    var body: some View
    {
        HStack
        {
            VStack(alignment: .leading)
            {
                Text(availableVersion.versionName)

                Text(availableVersion.releasedAt.formatted(date: .numeric, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu
        {
            ButtonThatOpensWebsites(websiteURL: availableVersion.githubPage, buttonText: "action.see-on-github")
        }
    }
}

private struct DownloadingSheetContents: View
{
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
            Group
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
                        .toolbar
                        {
                            ToolbarItem(placement: .cancellationAction)
                            {
                                AsyncButton
                                {
                                    await downloader.cancel()
                                } label: {
                                    Text("action.cancel")
                                }
                            }
                        }
                case .downloaded(let finalApplication):
                    downloadFinishedView(finalApplication: finalApplication)
                        .toolbar
                        {
                            ToolbarItem(placement: .primaryAction)
                            {
                                Button
                                {
                                    downgradeState.sheetToShow = nil
                                } label: {
                                    Text("add-package.install.finished")
                                }
                            }
                        }
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
            .padding()
        }
    }

    @ViewBuilder
    private func downloadFinishedView(finalApplication: Application) -> some View
    {
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

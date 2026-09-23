//
//  Downgrade Cork View.swift
//  Cork
//
//  Created by David Bureš - P on 20.09.2026.
//

import CorkShared
import SwiftUI
import FactoryKit
import ButtonKit

struct DowngradeCorkView: View
{
    @Observable
    class DowngradeState
    {
        enum Sheets: Identifiable
        {
            var id: UUID {
                return .init()
            }
            
            case downloading(versionToDowngradeTo: CorkVersion)
        }
        
        var sheetToShow: Sheets?
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
                case name = "name"
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
        case loading
        case loaded(versions: [CorkVersion])
        case failed(error: String)
    }

    @State private var availableVersionsLoadingState: AvailableVersionsDownloadingState = .loading
    
    @State private var downgradeState: DowngradeState = .init()

    var body: some View
    {
        Group
        {
            switch availableVersionsLoadingState
            {
            case .loading:
                ProgressView()
                    .task
                {
                    do
                    {
                        let downloadedAvailableVersions: [CorkVersion] = try await listPreviousCorkVersions()
                        
                        self.availableVersionsLoadingState = .loaded(versions: downloadedAvailableVersions)
                    }
                    catch let availableVersionListingError
                    {
                        self.availableVersionsLoadingState = .failed(error: availableVersionListingError.localizedDescription)
                    }
                }
            case .loaded(let versions):
                AvailableVersionsList(availableVersions: versions)
                    .sheet(item: Bindable(downgradeState).sheetToShow) { sheetType in
                        switch sheetType
                        {
                        case .downloading(let versionToDowngradeTo):
                            DownloadingSheetContents(versionToDowngradeTo: versionToDowngradeTo)
                        }
                    }
                    .environment(downgradeState)
            case .failed(let error):
                ContentUnavailableView {
                    Label("downgrade-cork.failed.title", image: "custom.arrow.down.app.badge.xmark")
                } description: {
                    Text(error)
                } actions: {
                    AsyncButton
                    {
                        do
                        {
                            let downloadedAvailableVersions: [CorkVersion] = try await listPreviousCorkVersions()
                            
                            self.availableVersionsLoadingState = .loaded(versions: downloadedAvailableVersions)
                        }
                        catch let availableVersionListingError
                        {
                            self.availableVersionsLoadingState = .failed(error: availableVersionListingError.localizedDescription)
                        }
                    } label: {
                        Text("add-tap.error.action")
                    }
                    .asyncButtonStyle(.pulse)
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

    var body: some View
    {
        List(selection: $selectedVersionToDowngradeToID)
        {
            ForEach(availableVersions)
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
    private let downloader: Downloader = .init()
    
    let versionToDowngradeTo: DowngradeCorkView.CorkVersion
    
    enum DownloadingState
    {
        case downloading
        case downloaded(locationOfDownloadedFileOnDisk: URL)
        case failed(error: Error)
    }
    
    @State private var downloadingState: DownloadingState = .downloading
    
    var body: some View
    {
        switch downloadingState
        {
        case .downloading:
            ProgressView()
                .task {
                    do
                    {
                        let finishedDownloadURL: URL = try await downloader.downloadFile(from: versionToDowngradeTo.assets.first(where: { $0.name == "Cork.zip" })!.browserDownloadUrl)
                        
                        AppConstants.shared.logger.info("Finished download of old version and it's at this URL: \(finishedDownloadURL)")
                    } catch let downloadingError {
                        AppConstants.shared.logger.error("Failed while downloading Cork release: \(downloadingError)")
                        return
                    }
                }
        case .downloaded(let locationOfDownloadedFileOnDisk):
            downloadFinishedView(withLocationOnDisk: locationOfDownloadedFileOnDisk)
        case .failed(let error):
            Text(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    private func downloadFinishedView(withLocationOnDisk locationOnDisk: URL) -> some View
    {
        Text(locationOnDisk.path())
    }
}

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

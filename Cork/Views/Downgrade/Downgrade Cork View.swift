//
//  Downgrade Cork View.swift
//  Cork
//
//  Created by David Bureš - P on 20.09.2026.
//

import CorkShared
import SwiftUI

struct DowngradeCorkView: View
{
    struct CorkVersion: Codable, Identifiable, Hashable
    {
        let id: UUID = .init()

        let versionName: String

        let versionDownloadURL: URL

        let isPrerelease: Bool

        private enum CodingKeys: String, CodingKey
        {
            case versionName = "name"
            case versionDownloadURL = "zipball_url"
            case isPrerelease = "prerelease"
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

    var body: some View
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
        case .failed(let error):
            ContentUnavailableView("downgrade-cork.failed.title", image: "custom.arrow.down.app.badge.xmark", description: Text(error))
        }
    }

    private func listPreviousCorkVersions() async throws(PreviousReleasesFetchingError) -> [CorkVersion]
    {
        AppConstants.shared.logger.debug("Will fetch previous versions of Cork")

        let downloadedData: Data

        do
        {
            downloadedData = try await downloadDataFromURL(.init(string: "https://api.github.com/repos/buresdv/cork/releases")!)
        }
        catch
        {
            AppConstants.shared.logger.error("Failed while downloading available versions: \(error)")
            throw .failedToDownload(error)
        }

        do
        {
            return try JSONDecoder().decode([CorkVersion].self, from: downloadedData).filter { !$0.isPrerelease }
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
    let availableVersions: [DowngradeCorkView.CorkVersion]

    @State private var selectedVersionToDowngradeToID: DowngradeCorkView.CorkVersion.ID?

    var body: some View
    {
        List(selection: $selectedVersionToDowngradeToID)
        {
            ForEach(availableVersions)
            { version in
                Text(version.versionName)
            }
        }
        .listStyle(.bordered)
        .alternatingRowBackgrounds(.enabled)
        .safeAreaInset(edge: .bottom, alignment: .trailing)
        {
            Button
            {
                if let selectedVersionToDowngradeToID, let selectedVersionToDowngradeTo = availableVersions.first(where: { $0.id == selectedVersionToDowngradeToID })
                {
                    print("Would download release \(selectedVersionToDowngradeTo.versionName), URL: \(selectedVersionToDowngradeTo.versionDownloadURL)")
                }
            } label: {
                Text("action.download")
            }
            .disabled(selectedVersionToDowngradeToID == nil)
        }
    }
}

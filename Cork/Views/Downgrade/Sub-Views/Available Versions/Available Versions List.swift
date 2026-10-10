//
//  Available Versions List.swift
//  Cork
//
//  Created by David Bureš - P on 10.10.2026.
//

import SwiftUI
import FactoryKit
import ButtonKit

struct AvailableVersionsList: View
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


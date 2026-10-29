//
//  Available Version List Row.swift
//  Cork
//
//  Created by David Bureš - P on 10.10.2026.
//

import SwiftUI

struct VersionListRow: View
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

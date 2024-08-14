//
//  Loading of Outdated Packages Failed List Box.swift
//  Cork
//
//  Created by David Bureš on 14.08.2024.
//

import SwiftUI

struct LoadingOfOutdatedPackagesFailedListBox: View
{
    let errorOutReason: String

    var body: some View
    {
        HStack(spacing: 15)
        {
            Image(systemName: "xmark.seal")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
            
            VStack(alignment: .leading, spacing: 2)
            {
                Text("start-page.loading.failed.title")
                
                Text(errorOutReason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(2)
    }
}

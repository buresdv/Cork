//
//  Outdated Package Loader Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct OutdatedPackageLoaderBox: View {
    var body: some View {
        GroupBox
        {
            Grid
            {
                GridRow(alignment: .firstTextBaseline) {
                    HStack(alignment: .center, spacing: 15)
                    {
                        ProgressView()

                        Text("start-page.updates.loading")
                    }
                    .padding(10)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

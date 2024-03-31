//
//  Brewfile Export Progress.swift
//  Cork
//
//  Created by David Bureš on 11.11.2023.
//

import SwiftUI

struct BrewfileExportProgressView: View
{
    var body: some View
    {
        HStack(alignment: .center, spacing: 20)
        {
            ProgressView()

            Text("brewfile.export.progress")
        }
        .padding()
    }
}

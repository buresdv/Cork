//
//  Brewbak Icon Proxy.swift
//  Cork
//
//  Created by David Bureš - P on 29.03.2026.
//

import SwiftUI

public struct BrewfileIconProxy: View
{
    let brewbak: BrewbakFile

    public init(brewbak: BrewbakFile)
    {
        self.brewbak = brewbak
    }
    
    public var body: some View
    {
        VStack(spacing: 4)
        {
            Image(nsImage: NSWorkspace.shared.icon(for: .brewbak))
                .resizable()
                .frame(width: 50, height: 50)

            Text("backup.brewbak-file.name")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .draggable(brewbak)
    }
}

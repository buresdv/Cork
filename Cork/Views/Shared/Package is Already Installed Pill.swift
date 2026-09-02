//
//  Package is Already Installed Pill.swift
//  Cork
//
//  Created by David Bureš - P on 12.08.2026.
//

import SwiftUI

struct PackageAlreadyInstalledPill: View
{
    var body: some View
    {
        Label("add-package.result.already-installed", systemImage: "shippingbox")
            .labelStyle(.pill(
                color: .init(
                    text: .green,
                    background: .green.opacity(0.15)
                ),
                iconStyle: .iconIsHidden
            ))
    }
}

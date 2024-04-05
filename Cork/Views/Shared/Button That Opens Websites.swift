//
//  Button That Opens Websites.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import AppKit
import Foundation
import SwiftUI

struct ButtonThatOpensWebsites: View
{
    let websiteURL: URL
    let buttonText: LocalizedStringKey

    var body: some View
    {
        Button
        {
            NSWorkspace.shared.open(websiteURL)
        } label: {
            Label(buttonText, systemImage: "safari")
        }
    }
}

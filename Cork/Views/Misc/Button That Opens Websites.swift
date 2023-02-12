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
    @State var websiteURL: URL
    @State var buttonText: String

    var body: some View
    {
        Button
        {
            NSWorkspace.shared.open(websiteURL)
        } label: {
            HStack(alignment: .center)
            {
                Text(buttonText)
                Image(systemName: "safari")
            }
        }
    }
}

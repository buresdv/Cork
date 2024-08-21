//
//  Open Terminal.swift
//  Cork
//
//  Created by David Bureš on 19.11.2023.
//

import AppKit
import Foundation

func openTerminal()
{
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") else { return }

    let path: String = "/bin"
    let configuration: NSWorkspace.OpenConfiguration = .init()
    configuration.arguments = [path]
    NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
}

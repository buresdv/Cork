//
//  Copy to Clipboard.swift
//  Cork
//
//  Created by David Bureš on 01.10.2023.
//

import AppKit
import Foundation

extension String
{
    func copyToClipboard()
    {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(self, forType: .string)
    }
}

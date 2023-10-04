//
//  Copy to Clipboard.swift
//  Cork
//
//  Created by David Bureš on 01.10.2023.
//

import Foundation
import AppKit

func copyToClipboard(whatToCopy: String)
{
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(whatToCopy, forType: .string)
}

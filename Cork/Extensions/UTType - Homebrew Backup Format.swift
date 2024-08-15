//
//  UTType - Homebrew Backup Format.swift
//  Cork
//
//  Created by David Bureš on 11.11.2023.
//

import Foundation
import UniformTypeIdentifiers

extension UTType
{
    static var homebrewBackup: UTType
    {
        UTType(exportedAs: "com.davidbures.homebrew-backup")
    }
}

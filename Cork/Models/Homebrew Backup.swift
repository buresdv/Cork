//
//  Homebrew Backup.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import Foundation
import SwiftUI

struct HomebrewBackup: Transferable
{
    let url: URL
    
    let contents: String?
    
    static var transferRepresentation: some TransferRepresentation
    {
        FileRepresentation(contentType: .homebrewBackup) { export in
            SentTransferredFile(export.url)
        } importing: { received in
            let copy: URL = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .homebrewBackup)
            try FileManager.default.copyItem(at: received.file, to: copy)
            
            return self.init(url: copy, contents: try String(contentsOfFile: copy.path, encoding: .utf8))
        }

    }
}

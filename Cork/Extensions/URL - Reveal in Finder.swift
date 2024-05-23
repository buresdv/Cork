//
//  URL - Reveal in Finder.swift
//  Cork
//
//  Created by David Bureš on 23.05.2024.
//

import Foundation
import AppKit

enum FolderOpeningType
{
    case openDirectoryItself, openParentDirectoryAndHighlightTarget
}

extension URL
{
    func revealInFinder(_ folderOpeningType: FolderOpeningType)
    {
        switch folderOpeningType {
            case .openDirectoryItself:
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: self.path)
            case .openParentDirectoryAndHighlightTarget:
                NSWorkspace.shared.selectFile(self.path, inFileViewerRootedAtPath: self.deletingLastPathComponent().path)
        }
    }
}

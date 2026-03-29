//
//  Brewbak Transferable.swift
//  Cork
//
//  Created by David Bureš - P on 29.03.2026.
//

import CoreTransferable
import UniformTypeIdentifiers

public struct BrewbakFile: Transferable
{
    public let text: String

    public static var transferRepresentation: some TransferRepresentation
    {
        FileRepresentation(exportedContentType: .brewbak)
        { contents in
            let url = FileManager.default.temporaryDirectory
                .appending(component: "Brewfile", directoryHint: .notDirectory)

            try contents.text.write(to: url, atomically: true, encoding: .utf8)

            return SentTransferredFile(url)
        }
    }

    public init(text: String)
    {
        self.text = text
    }
}

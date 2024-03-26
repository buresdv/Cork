//
//  DataFile.swift
//  Cork
//
//  Created by David Bureš on 10.11.2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct StringFile: FileDocument, Transferable
{
    static var readableContentTypes: [UTType] { [.homebrewBackup, .plainText] }
    static var writableContentTypes: [UTType] { [.homebrewBackup] }
    
    static var transferRepresentation: some TransferRepresentation
    {
        FileRepresentation(importedContentType: .homebrewBackup) { received in
            do
            {
                return try StringFile(initialText: String(contentsOf: received.file))
            }
            catch
            {
                throw CocoaError(.fileReadCorruptFile)
            }
        }
    }

    var text: String

    init(initialText: String = "")
    {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws
    {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else
        {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper
    {
        let data = text.data(using: .utf8)
        return FileWrapper(regularFileWithContents: data ?? Data())
    }
}

struct DataFile: FileDocument, Transferable
{
    static var readableContentTypes: [UTType] { [.data, .homebrewBackup] }
    static var writableContentTypes: [UTType] { [.data, .homebrewBackup] }
    
    static var transferRepresentation: some TransferRepresentation
    {
        FileRepresentation(importedContentType: .homebrewBackup) { received in
            do
            {
                return try DataFile(initialData: Data(contentsOf: received.file))
            }
            catch
            {
                throw CocoaError(.fileReadCorruptFile)
            }
        }
    }

    var data: Data

    init(initialData: Data = Data())
    {
        data = initialData
    }

    init(configuration: ReadConfiguration) throws
    {
        if let fileData = configuration.file.regularFileContents
        {
            data = fileData
        }
        else
        {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper
    {
        return FileWrapper(regularFileWithContents: data)
    }
}

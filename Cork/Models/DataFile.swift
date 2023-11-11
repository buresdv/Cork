//
//  DataFile.swift
//  Cork
//
//  Created by David Bureš on 10.11.2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DataFile: FileDocument
{
    static var readableContentTypes: [UTType] { [.data, .homebrewBackup] }
    static var writableContentTypes: [UTType] { [.data, .homebrewBackup] }
    
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

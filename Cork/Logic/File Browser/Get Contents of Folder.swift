//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func getContentsOfFolder(targetFolder: URL) async -> [String] {
    var contentsOfFolder = [String]()
    
    do {
        let items = try FileManager.default.contentsOfDirectory(atPath: targetFolder.path)
        for item in items {
            contentsOfFolder.append(item)
        }
    } catch let error as NSError {
        print("Failed while accessing foldeR: \(error)")
    }
    
    return contentsOfFolder
}

//
//  Get Contents of Folder.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func getContentsOfFolder(targetFolder: URL) async -> [BrewPackage] {
    var contentsOfFolder = [BrewPackage]()
    
    do {
        let items = try FileManager.default.contentsOfDirectory(atPath: targetFolder.path)
        
        for item in items {
            do {
                let versions = try FileManager.default.contentsOfDirectory(atPath: targetFolder.appendingPathComponent(item, conformingTo: .folder).path)
                
                contentsOfFolder.append(BrewPackage(name: item, versions: versions))
                
            } catch let error as NSError {
                print("Failed while getting package version: \(error)")
            }
            
        }
        
    } catch let error as NSError {
        print("Failed while accessing foldeR: \(error)")
    }
    
    return contentsOfFolder
}

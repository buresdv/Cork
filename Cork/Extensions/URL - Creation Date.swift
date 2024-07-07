//
//  URL - Creation Date.swift
//  Cork
//
//  Created by David Bureš on 07.07.2024.
//

import Foundation

extension URL
{
    var creationDate: Date?
    {
        guard let attributesOfSpecifiedURL: [FileAttributeKey : Any] = try? FileManager.default.attributesOfItem(atPath: self.path) else
        {
            return nil
        }
        
        return attributesOfSpecifiedURL[.creationDate] as? Date
    }
}

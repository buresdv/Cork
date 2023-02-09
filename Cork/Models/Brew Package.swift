//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

struct BrewPackage: Identifiable
{
    let id = UUID()
    let name: String
    let installedOn: Date?
    let versions: [String]
    
    func convertDateToPresentableFormat(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm E, d MMM y"

        return dateFormatter.string(from: date)
    }
}

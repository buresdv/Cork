//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

struct BrewPackage: Identifiable, Equatable
{
    var id = UUID()
    let name: String
    
    let isCask: Bool
    var isTagged: Bool = false
    
    let installedOn: Date?
    let versions: [String]
    
    var installedIntentionally: Bool = true
    
    let url: [URL]
    
    let sizeInBytes: Int64?
}

extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        Self.dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}

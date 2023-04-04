//
//  Pin an Unpit Package.swift
//  Cork
//
//  Created by David Bureš on 07.03.2023.
//

import Foundation

func pinAndUnpinPackage(package: BrewPackage, pinned: Bool) async -> Void
{
    if pinned
    {
        let pinResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["pin", package.name])
        
        if !pinResult.standardError.isEmpty
        {
            print("Error pinning: \(pinResult.standardError)")
        }
    }
    else
    {
        let unpinResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["unpin", package.name])
        if !unpinResult.standardError.isEmpty
        {
            print("Error unpinning: \(unpinResult.standardError)")
        }
    }
}

//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation

func addTap(name: String) async -> String
{
    let tapResult = await shell(AppConstants.brewExecutablePath, ["tap", name]).standardError

    print("Tapping result: \(tapResult)")

    return tapResult
}

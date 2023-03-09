//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import Foundation
import SwiftUI

func updatePackages() async -> Void
{
    for await output in shell("/opt/homebrew/bin/brew", ["update"])
    {
        switch output
        {
            case let .standardOutput(outputLine):
                print("Update function output: \(outputLine)")
                
            case let .standardError(errorLine):
                print("Update function error: \(errorLine)")
                
        }
    }
}

//
//  Navigation Destinations - Main Window.swift
//  Cork
//
//  Created by David Bureš on 14.10.2024.
//

import Foundation
import CorkModels

enum NavigationTargetMainWindow: Hashable
{
    case package(BrewPackage)
    case tap(BrewTap)
}

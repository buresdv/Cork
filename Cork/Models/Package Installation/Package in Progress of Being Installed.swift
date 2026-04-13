//
//  Package in Progress of Being Installed.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkModels
import CorkTerminalFunctions

struct RealTimeTerminalLine: Identifiable, Hashable, Equatable
{
    let id: UUID = .init()
    let line: TerminalOutput
}

struct PackageInProgressOfBeingInstalled: Identifiable
{
    let id: UUID = .init()

    let package: BrewPackage
    var installationStage: PackageInstallationStage
    var packageInstallationProgress: Double

    var realTimeTerminalOutput: [RealTimeTerminalLine] = .init()
}

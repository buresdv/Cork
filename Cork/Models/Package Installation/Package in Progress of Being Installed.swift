//
//  Package in Progress of Being Installed.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

struct RealTimeTerminalLine: Identifiable, Hashable, Equatable
{
    let id: UUID = .init()
    let line: String
}

struct PackageInProgressOfBeingInstalled: Identifiable
{
    let id: UUID = .init()

    let package: BrewPackage
    var installationStage: PackageInstallationStage
    var packageInstallationProgress: Double

    var realTimeTerminalOutput: [RealTimeTerminalLine] = .init()
}

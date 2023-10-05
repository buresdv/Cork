//
//  Package Installation Status.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

enum PackageInstallationStage
{
    case ready, loadingDependencies, fetchingDependencies, installingDependencies, installingPackage, finished // For Formulae
    
    case downloadingCask, installingCask, movingCask, linkingCaskBinary // For Casks

    case requiresSudoPassword, obtainedSudoPermissions // For Both
}

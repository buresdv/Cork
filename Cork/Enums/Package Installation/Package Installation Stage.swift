//
//  Package Installation Status.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

enum PackageInstallationStage: CustomStringConvertible
{
    case ready, loadingDependencies, fetchingDependencies, installingDependencies, installingPackage, finished // For Formulae

    case downloadingCask, installingCask, movingCask, linkingCaskBinary // For Casks

    case requiresSudoPassword, wrongArchitecture // For Both

    var description: String
    {
        switch self
        {
        case .ready:
            return "Ready"
        case .loadingDependencies:
            return "Loading Dependencies"
        case .fetchingDependencies:
            return "Fetching Dependencies"
        case .installingDependencies:
            return "Installing Dependencies"
        case .installingPackage:
            return "Installing Package"
        case .finished:
            return "Installation Finished"
        case .downloadingCask:
            return "Downloaing Cask"
        case .installingCask:
            return "Installing Cask"
        case .movingCask:
            return "Moving Cask"
        case .linkingCaskBinary:
            return "Linking Cask Binary"
        case .requiresSudoPassword:
            return "Sudo PasswordRequired"
        case .wrongArchitecture:
            return "Wrong package architecture"
        }
    }
}

//
//  Package Installation Status.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

enum PackageInstallationStatus
{
    case ready, loadingDependencies, fetchingDependencies, installingDependencies, installingPackage, finished
}

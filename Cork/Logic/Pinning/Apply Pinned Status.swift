//
//  Apply Pinned Status.swift
//  Cork
//
//  Created by David Bureš - P on 12.06.2025.
//

import Foundation
import CorkShared

extension BrewDataStorage
{
    @MainActor
    func applyPinnedStatus(namesOfPinnedPackages: Set<String>) async
    {
        for pinnedPackageName in namesOfPinnedPackages
        {
            self.installedFormulae = Set(self.installedFormulae.map { formula in
                switch formula
                {
                case .success(var success):
                    if pinnedPackageName == success.name {
                        success.changePinnedStatus(to: .pinned)
                    }
                    return .success(success)
                case .failure(let failure):
                    return .failure(failure)
                }
            })
        }
    }
}

//
//  Apply Pinned Status.swift
//  Cork
//
//  Created by David Bureš - P on 12.06.2025.
//

import CorkShared
import Foundation

extension BrewDataStorage
{
    @MainActor
    func applyPinnedStatus(namesOfPinnedPackages: Set<String>) async
    {
        var newFormulae: BrewPackages = .init()

        for formula in self.installedFormulae
        {
            switch formula
            {
            case .success(var success):
                if namesOfPinnedPackages.contains(success.name)
                {
                    success.changePinnedStatus(to: .pinned)
                }
                else
                {
                    success.changePinnedStatus(to: .unpinned)
                }
                newFormulae.insert(.success(success))
            case .failure(let failure):
                newFormulae.insert(.failure(failure))
            }
        }

        self.installedFormulae = newFormulae
    }
}

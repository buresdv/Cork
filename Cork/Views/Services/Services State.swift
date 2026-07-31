//
//  Services State.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

@Observable @MainActor
class ServicesState
{
    // MARK: - State

    var isLoadingServices: Bool = true

    // MARK: - Errors

    var isShowingError: Bool = false
    var errorToShow: ServicesFatalError?

    func showError(_ errorToShow: ServicesFatalError)
    {
        self.errorToShow = errorToShow
        isShowingError = true
    }

    func dismissError()
    {
        isShowingError = false
        self.errorToShow = nil
    }
}

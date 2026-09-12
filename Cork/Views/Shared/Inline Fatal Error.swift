//
//  Inline Fatal Error.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation
import SwiftUI

struct InlineFatalError: View
{
    let errorMessage: LocalizedStringKey

    let errorDescription: String?

    /// This init has to be here so ``errorDescription`` is actually optional
    init(errorMessage: LocalizedStringKey, errorDescription: String? = nil)
    {
        self.errorMessage = errorMessage
        self.errorDescription = errorDescription
    }

    var body: some View
    {
        Group
        {
            if let errorDescription
            {
                ContentUnavailableView(errorMessage, systemImage: "exclamationmark.triangle.fill", description: Text(errorDescription))
            }
            else
            {
                ContentUnavailableView(errorMessage, image: "exclamationmark.triangle.fill")
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

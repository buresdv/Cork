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
            if #available(macOS 14.0, *)
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
            else
            {
                VStack(alignment: .center, spacing: 10)
                {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    // .scaledToFit()
                    Text(errorMessage)
                        .multilineTextAlignment(.center)

                    if let errorDescription
                    {
                        Text(errorDescription)
                    }

                    Button
                    {
                        restartApp()
                    } label: {
                        Text("action.restart")
                    }
                }
                .foregroundColor(.gray)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

//
//  Tap - Error.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import SwiftUI

struct AddTapErrorView: View
{
    let tappingError: TappingError
    let requestedTap: String
    
    @Binding var progress: TapAddingStates
    
    var body: some View
    {
        ComplexWithIcon(systemName: "xmark.seal")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    switch tappingError
                    {
                        case .repositoryNotFound:
                            Text("add-tap.error.repository-not-found-\(requestedTap)")
                                .font(.headline)
                            Text("add-tap.error.repository-not-found.description")
                            
                        case .other:
                            Text("add-tap.error.other-\(requestedTap)")
                                .font(.headline)
                            Text("add-tap.error.other.description")
                    }
                }

                HStack
                {
                    DismissSheetButton()

                    Spacer()
                    
                    if tappingError == .repositoryNotFound
                    {
                        Button
                        {
                            progress = .manuallyInputtingTapRepoAddress
                        } label: {
                            Text("add-tap.manual-repo-address.show")
                        }
                    }

                    Button
                    {
                        progress = .ready
                    } label: {
                        Text("add-tap.error.action")
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .frame(width: 320)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

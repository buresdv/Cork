//
//  Tap - Initial.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import CorkModels
import CorkShared
import SwiftUI

struct AddTapInitialView: View
{
    @Binding var requestedTap: String
    @Binding var forcedRepoAddress: String
    @Binding var progress: TapAddingStates

    @State private var isShowingErrorPopover: Bool = false
    @State var tapInputError: TapInputErrors = .empty

    let isShowingManualRepoAddressInputField: Bool

    @FocusState var isForcedAddressFieldFocused: Bool

    static private let tapNameValidityRegex: Regex = try! .init(".+\\/.+")

    private var isSubmitButtonDisabled: Bool
    {
        return !requestedTap.contains(Self.tapNameValidityRegex)
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            TextField("homebrew/core", text: $requestedTap)
                .popover(isPresented: $isShowingErrorPopover)
                {
                    VStack(alignment: .leading)
                    {
                        switch tapInputError
                        {
                        case .empty:
                            Text("add-tap.typing.error.empty")
                                .font(.headline)
                            Text("add-tap.typing.error.empty.description")
                        case .missingSlash:
                            Text("add-tap.typing.error.slash")
                                .font(.headline)
                            Text("add-tap.typing.error.slash.description")
                        case .invalidHost:
                            Text("add-tap.typing.error.invalid-host")
                                .font(.headline)
                            Text("add-tap.typing.error.invalid-host.description")
                        case .invalidName(let error):
                            Text("add-tap.typing.error.invalid-name")
                                .font(.headline)
                            Text(error.localizedDescription)
                        }
                    }
                    .padding()
                }

            DisclosureGroup("add-tap.customize-tap.label")
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    // Text("add-tap.manual-repo-address.label")
                    // .font(.subheadline)
                    
                    LabeledContent
                    {
                        TextField(text: $forcedRepoAddress)
                        {
                            Text("https://github.com")
                        }
                    } label: {
                        Text("")
                    }

                    // TextField("https://github.com/", value: $forcedRepoAddress, format: .urlEnforcingTrailingSlash)
                }
            }
        }
        .toolbar
        {
            ToolbarItem(placement: .primaryAction)
            {
                Button
                {
                    do throws(TapInputErrors)
                    {
                        try submitTapName(tapName: requestedTap, forcedHost: forcedRepoAddress)
                    } catch let tapValidationError {
                        self.tapInputError = tapValidationError
                    }
                } label: {
                    Text("add-tap.action")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isSubmitButtonDisabled)
            }
        }
    }

    private func submitTapName(tapName: String, forcedHost: String) throws(TapInputErrors)
    {
        enum Host
        {
            case gitHub
            case custom(URL)
        }

        if tapName.isEmpty
        {
            throw .empty
        }
        else if !tapName.contains("/")
        {
            throw .missingSlash
        }

        guard let constructedHost: URL = .init(string: forcedHost)
        else
        {
            throw .invalidHost
        }

        var finalHost: Host

        if constructedHost == AppConstants.shared.gitHubURL
        {
            finalHost = .gitHub
        }
        else
        {
            finalHost = .custom(constructedHost)
        }

        let externalRepo: URL? = switch finalHost
        {
        case .gitHub: nil
        case .custom(let url): url
        }

        do
        {
            let constructedTap: BrewTap = try .init(externalRepo: externalRepo, name: tapName)
            
            progress = .tapping(tap: constructedTap)
        } catch let tapInitializationError {
            throw .invalidName(tapInitializationError)
        }
    }
}

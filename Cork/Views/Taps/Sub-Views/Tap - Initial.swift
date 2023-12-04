//
//  Tap - Initial.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import SwiftUI

struct AddTapInitialView: View
{
    @Binding var requestedTap: String
    @Binding var isShowingSheet: Bool
    @Binding var progress: TapAddingStates

    @State private var isShowingErrorPopover: Bool = false
    @State var tapInputError: TapInputErrors = .empty

    var body: some View
    {
        SheetWithTitle(title: "add-tap")
        {
            TextField("homebrew/core", text: $requestedTap)
                .onSubmit
                {
                    checkIfTapNameIsValid(tapName: requestedTap)
                }
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
                        }
                    }
                    .padding()
                }

            HStack
            {
                Button
                {
                    isShowingSheet.toggle()
                } label: {
                    Text("action.cancel")
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button
                {
                    checkIfTapNameIsValid(tapName: requestedTap)

                    if !isShowingErrorPopover
                    {
                        progress = .tapping
                    }
                } label: {
                    Text("add-tap.action")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(validateTapName(tapName: requestedTap) != nil)
            }
        }
    }

    private func validateTapName(tapName: String) -> TapInputErrors?
    {
        if tapName.isEmpty
        {
            return .empty
        }
        else if !tapName.contains("/")
        {
            return .missingSlash
        }

        return nil
    }

    private func checkIfTapNameIsValid(tapName: String)
    {
        if let error = validateTapName(tapName: tapName)
        {
            tapInputError = error
            isShowingErrorPopover = true
        }
    }
}

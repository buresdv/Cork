//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import SwiftUI

enum TapAddingStates
{
    case ready, tapping, finished, error
}

enum TapInputErrors
{
    case empty, missingSlash
}

enum TappingError: String
{
    case repositoryNotFound = "Repository not found"
    case other = "An error occured while tapping"
}

struct AddTapView: View
{
    @Binding var isShowingSheet: Bool

    @State var progress: TapAddingStates = .ready
    @State var tapInputError: TapInputErrors = .empty

    @State private var requestedTap: String = ""

    @State private var isShowingErrorPopover: Bool = false

    @State private var tappingError: TappingError = .other

    @EnvironmentObject var availableTaps: AvailableTaps
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        VStack
        {
            switch progress
            {
            case .ready:
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

            case .tapping:
                ProgressView
                {
                    Text("add-tap.progress-\(requestedTap)")
                }
                .task(priority: .medium)
                {
                    let tapResult = await addTap(name: requestedTap)

                    print("Result: \(tapResult)")

                    if tapResult.contains("Tapped")
                    {
                        print("Tapping was successful!")
                        progress = .finished
                    }
                    else
                    {
                        progress = .error
                        tappingError = .other

                        if tapResult.contains("Repository not found")
                        {
                            print("Repository was not found")

                            tappingError = .repositoryNotFound
                        }
                    }
                }
            case .finished:
                ComplexWithIcon(systemName: "checkmark.seal")
                {
                    DisappearableSheet(isShowingSheet: $isShowingSheet)
                    {
                        HeadlineWithSubheadline(
                            headline: "add-tap.complete-\(requestedTap)",
                            subheadline: "add-tap.complete.description",
                            alignment: .leading
                        )
                        .fixedSize(horizontal: true, vertical: true)
                        .onAppear
                        {
                            withAnimation {
                                availableTaps.addedTaps.prepend(BrewTap(name: requestedTap))
                            }

                            /// Remove that one element of the array that's empty for some reason
                            availableTaps.addedTaps.removeAll(where: { $0.name == "" })

                            print("Available taps: \(availableTaps.addedTaps)")
                        }
                        .task(priority: .background)
                        { // Force-load the packages from the new tap
                            print("Will update packages")
                            await shell(AppConstants.brewExecutablePath.absoluteString, ["update"])
                        }
                    }
                }

            case .error:
                ComplexWithIcon(systemName: "xmark.seal")
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

                        HStack
                        {
                            DismissSheetButton(isShowingSheet: $isShowingSheet)

                            Spacer()

                            Button
                            {
                                progress = .ready
                            } label: {
                                Text("add-tap.error.action")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    .frame(width: 200)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
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

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

    var body: some View
    {
        VStack
        {
            switch progress
            {
            case .ready:
                SheetWithTitle(title: "Tap a tap")
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
                                    Text("Tap name empty")
                                        .font(.headline)
                                    Text("You didn't put in any tap name")
                                case .missingSlash:
                                    Text("Tap name needs a slash")
                                        .font(.headline)
                                    Text("Tap names always have to contain a slash")
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
                            Text("Cancel")
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
                            Text("Tap")
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }

            case .tapping:
                ProgressView
                {
                    Text("Tapping \(requestedTap)")
                }
                .onAppear
                {
                    Task
                    {
                        let tapResult = await tapAtap(tapName: requestedTap)

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
                }
            case .finished:
                ComplexWithIcon(systemName: "checkmark.seal") {
                    DisappearableSheet(isShowingSheet: $isShowingSheet)
                    {
                        HeadlineWithSubheadline(headline: "Successfully tapped \(requestedTap)", subheadline: "There were no errors", alignment: .leading)
                            .fixedSize(horizontal: true, vertical: true)
                            .onAppear
                            {
                                availableTaps.tappedTaps.append(BrewTap(name: requestedTap))
                            }
                    }
                }

            case .error:
                ComplexWithIcon(systemName: "xmark.seal") {
                    VStack(alignment: .leading, spacing: 5)
                    {
                        switch tappingError {
                        case .repositoryNotFound:
                                Text("\(requestedTap) doesn't exist")
                                    .font(.headline)
                                Text("Double-check that you wrote the name right")
                        
                        case .other:
                            Text("An error occured while tapping \(requestedTap)")
                                .font(.headline)
                            Text("Try tapping it again in a few minutes")
                        }

                        HStack
                        {
                            DismissSheetButton(isShowingSheet: $isShowingSheet)
                            
                            Spacer()

                            Button
                            {
                                progress = .ready
                            } label: {
                                Text("Try Again")
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

    func checkIfTapNameIsValid(tapName: String)
    {
        if tapName.isEmpty
        {
            tapInputError = .empty
            isShowingErrorPopover = true
        }
        else if !tapName.contains("/")
        {
            tapInputError = .missingSlash
            isShowingErrorPopover = true
        }
    }
}

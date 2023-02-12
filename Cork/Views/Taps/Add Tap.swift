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

struct AddTapView: View
{
    @Binding var isShowingSheet: Bool

    @State var progress: TapAddingStates = .ready
    @State var tapInputError: TapInputErrors = .empty

    @State private var requestedTap: String = ""

    @State private var isShowingErrorPopover: Bool = false
    
    @StateObject var availableTaps: AvailableTaps

    var body: some View
    {
        VStack
        {
            switch progress
            {
            case .ready:
                VStack(alignment: .leading)
                {
                    Text("Tap a tap")
                        .font(.headline)
                    TextField("homebrew/core", text: $requestedTap)
                        .onSubmit
                        {
                            checkIfTapNameIsValid(tapName: requestedTap)
                        }
                        .popover(isPresented: $isShowingErrorPopover)
                        {
                            switch tapInputError
                            {
                            case .empty:
                                VStack(alignment: .leading)
                                {
                                    Text("Tap name empty")
                                        .font(.headline)
                                    Text("You didn't put in any tap name")
                                }
                                .padding()
                            case .missingSlash:
                                VStack(alignment: .leading)
                                {
                                    Text("Tap name needs a slash")
                                        .font(.headline)
                                    Text("Tap names always have to contain a slash")
                                }
                                .padding()
                            }
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
                    .padding(.top)
                }
                .frame(width: 200)

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

                        print("The task finished")

                        print("Result: \(tapResult)") // Why does this shit not FUCKING WORK
                        
                        let debugResult = await shell("/opt/homebrew/bin/brew", ["outdated"]).standardOutput
                        print("Sanity debug result: \(debugResult)")

                        #warning("Remove this in production. It untaps the tap right after")
                        let untapResult = await shell("/opt/homebrew/bin/brew", ["untap", requestedTap]).standardOutput
                        print("Untap Result: \(untapResult)")

                        progress = .finished // TODO: Make this actually check if it successfully tapped the tap
                    }
                }
            case .finished:
                VStack
                {
                    Text("Successfully tapped \(requestedTap)")
                        .font(.headline)
                        .onAppear
                        {
                            
                            availableTaps.tappedTaps.append(BrewTap(name: requestedTap))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                            {
                                isShowingSheet = false
                            }
                        }
                    Text("There were no errors")
                }

            case .error:
                VStack
                {
                    HStack(spacing: 10)
                    {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)

                        VStack(alignment: .leading)
                        {
                            Text("An error occured while tapping \(requestedTap)")
                                .font(.headline)
                            Text("Make sure you got the tap name right")
                        }
                    }

                    HStack
                    {
                        Spacer()

                        Button
                        {
                            isShowingSheet.toggle()
                        } label: {
                            Text("Close")
                        }
                    }
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

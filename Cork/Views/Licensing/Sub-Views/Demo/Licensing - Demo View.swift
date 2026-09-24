//
//  Licensing - Demo View.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels
import FactoryKit
import EventKit

struct Licensing_DemoView: View
{
    @Default(.demoActivatedAt) var demoActivatedAt: Date?

    @Environment(\.dismiss) var dismiss: DismissAction

    @InjectedObservable(\.appState) var appState: AppState

    var body: some View
    {
        NavigationStack
        {
            VStack(alignment: .center, spacing: 15)
            {
                if let demoActivatedAt
                {
                    Text("licensing.demo-activated.title")
                        .font(.title)

                    Text("licensing.demo.time-until-\((demoActivatedAt + AppConstants.shared.demoLengthInSeconds).formatted(date: .complete, time: .complete))")
                }
            }
            .padding()
            .fixedSize()
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction)
                {
                    Button
                    {
                        dismiss()
                    } label: {
                        Text("action.close")
                    }
                    .keyboardShortcut(.cancelAction)
                }

                ToolbarItem(placement: .primaryAction)
                {
                    Button
                    {
                        appState.licensingState = .notBoughtOrHasNotActivatedDemo
                    } label: {
                        Text("action.check-license")
                    }
                    .keyboardShortcut(.defaultAction)
                }

                /*
                ToolbarItem(placement: .automatic)
                {
                    Button
                    {
                        addReminderAboutDemoRuningOut()
                    } label: {
                        Text("action.add-reminder")
                    }

                }
                 */
            }
        }
    }
}

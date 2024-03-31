//
//  Licensing - Not Bought Or Activated View.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import SwiftUI

struct Licensing_NotBoughtOrActivatedView: View
{
    @AppStorage("demoActivatedAt") var demoActivatedAt: Date?

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var appState: AppState

    @State private var emailFieldContents: String = ""

    @State private var isCheckingLicense: Bool = false
    @State private var hasCheckingFailed: Bool = false

    var isDemoButtonDisabled: Bool
    { // Disable the Demo button if the user activated it before, and if it has been at least 7 days since the user activated the demo
        if let demoActivatedAt
        {
            let timeIntervalSinceDemoWasActivated: TimeInterval = demoActivatedAt.timeIntervalSinceNow

            if timeIntervalSinceDemoWasActivated < AppConstants.demoLengthInSeconds
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }

    var body: some View
    {
        VStack(alignment: .center, spacing: 15)
        {
            Text("licensing.not-bought-or-activated.title")
                .font(.title)

            Text("licensing.not-bought-or-activated.body")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .fixedSize()

            VStack(alignment: .leading, spacing: 5)
            {
                Text("licensing.email")

                HStack(alignment: .center, spacing: 20)
                {
                    TextField(text: $emailFieldContents, prompt: Text("licensing.email-field.prompt"))
                    {
                        Text("licensing.email")
                    }

                    if isCheckingLicense
                    {
                        if !hasCheckingFailed
                        {
                            ProgressView()
                                .scaleEffect(0.5, anchor: .center)
                                .frame(width: 1, height: 1)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        else
                        {
                            OutlinedPillText(text: "licensing.invalid-email", color: .secondary)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 10)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5)
                {
                    ButtonThatOpensWebsites(websiteURL: URL(string: "https://corkmac.app/create-checkout-session.php")!, buttonText: "action.buy")
                        .labelStyle(.titleOnly)

                    Text("licensing.price.copy")
                        .font(.subheadline)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }

                Spacer()

                if let demoActivatedAt
                {
                    if ((demoActivatedAt.timeIntervalSinceNow) + AppConstants.demoLengthInSeconds) > 0
                    { // Check if there is still time on the demo
                        Button
                        {
                            dismiss()
                        } label: {
                            Text("action.close")
                        }
                        .keyboardShortcut(.cancelAction)
                    }
                    else
                    {
                        Button
                        {
                            /// Nothing should be here, since the demo cannot be activated again
                        } label: {
                            Text("action.activate-demo")
                        }
                        .disabled(isDemoButtonDisabled)
                    }
                }
                else
                {
                    Button
                    {
                        demoActivatedAt = .now
                    } label: {
                        Text("action.activate-demo")
                    }
                    .disabled(isDemoButtonDisabled)
                }

                Button
                {
                    Task(priority: .userInitiated)
                    {
                        withAnimation
                        {
                            isCheckingLicense = true
                        }

                        defer
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                            {
                                withAnimation
                                {
                                    isCheckingLicense = false
                                    hasCheckingFailed = false
                                }
                            }
                        }

                        do
                        {
                            let hasSpecifiedUserBoughtCork: Bool = try await checkIfUserBoughtCork(for: emailFieldContents)

                            AppConstants.logger.debug("Has \(emailFieldContents) bought Cork? \(hasSpecifiedUserBoughtCork ? "YES" : "NO")")

                            if hasSpecifiedUserBoughtCork
                            {
                                appState.licensingState = .bought
                            }
                            else
                            {
                                withAnimation
                                {
                                    hasCheckingFailed = true
                                }
                            }
                        }
                        catch let licenseCheckingError as CorkLicenseRetrievalError
                        {
                            switch licenseCheckingError
                            {
                            case .authorizationComplexNotEncodedProperly:
                                appState.showAlert(errorToShow: .licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly)
                            }
                        }
                    }
                } label: {
                    Text("action.check-license")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(emailFieldContents.isEmpty || !emailFieldContents.contains("@") || !emailFieldContents.contains("."))
            }
        }
        .padding()
        .fixedSize()
        .animation(.easeInOut, value: isCheckingLicense)
        .animation(.easeInOut, value: hasCheckingFailed)
        .onAppear
        {
            if let demoActivatedAt
            {
                let timeIntervalSinceDemoWasActivated: TimeInterval = demoActivatedAt.timeIntervalSinceNow
                AppConstants.logger.debug("Time interval since demo was activated: \(timeIntervalSinceDemoWasActivated, privacy: .public)")
            }
        }
    }
}

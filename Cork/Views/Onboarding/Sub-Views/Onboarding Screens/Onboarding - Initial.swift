//
//  Onboarding - Initial.swift
//  Cork
//
//  Created by David Bureš - P on 19.09.2026.
//

import SwiftUI

struct Onboarding_InitialView: View
{
    @Environment(OnboardingView.OnboardingNavigationManager.self) var onboardingNavigationManager

    var body: some View
    {
        VStack(alignment: .center, spacing: 20)
        {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 100, height: 100)

            VStack(alignment: .center, spacing: 5, content: {
                Text("onboarding.title")
                    .font(.title)

                Text("onboarding.subtitle")
                
                Text("disclaimer.not-affiliated-with-homebrew")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            })
        }
        .toolbar
        {
            ToolbarItem(placement: .primaryAction)
            {
                Button
                {
                    onboardingNavigationManager.navigate(to: .corkFeatures)
                } label: {
                    Label("action.continue", systemImage: "")
                }
            }
        }
    }
}

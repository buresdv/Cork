//
//  About View.swift
//  Cork
//
//  Created by David Bureš on 07.07.2022.
//

import DavidFoundation
import SwiftUI

struct AboutView: View
{
    @State private var usedPackages: [UsedPackage] = [
        UsedPackage(name: "DavidFoundation", whyIsItUsed: "My own package that provides some basic convenience features", packageURL: URL(string: "https://github.com/buresdv/DavidFoundation")!),
        UsedPackage(name: "SwiftyJSON", whyIsItUsed: "I hate default JSON parsing in Swift. Why reinvent the wheel when you can just use a library to make it bearable?", packageURL: URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!)
    ]

    @State private var specialThanks: [AcknowledgedContributor] = [
        AcknowledgedContributor(name: "Seb Jachec", reasonForAcknowledgement: "Implemented a function for getting real-time outputs of commands, making more than half of all features in Cork much faster", profileService: "GitHub", profileURL: URL(string: "https://github.com/sebj")!),
    ]
    @State private var acknowledgedContributors: [AcknowledgedContributor] = [
        AcknowledgedContributor(name: "Rob Napier", reasonForAcknowledgement: "Gave invaluable help with all sorts of problems, from async Swift to blocking package installations", profileService: "Mastodon", profileURL: URL(string: "https://elk.zone/mstdn.social/@cocoaphony@mastodon.social")!),
        AcknowledgedContributor(name: "Łukasz Rutkowski", reasonForAcknowledgement: "Fixed many async and SwiftUI problems", profileService: "Mastodon", profileURL: URL(string: "https://elk.zone/mstdn.social/@luckkerr@mastodon.world")!),
        AcknowledgedContributor(name: "Jierong Li", reasonForAcknowledgement: "Fixed package counts on the start page not updating", profileService: "Mastodon", profileURL: URL(string: "https://elk.zone/mstdn.social/@jierongli@mastodon.social")!),
        AcknowledgedContributor(name: "Oscar Bazaldua", reasonForAcknowledgement: "Made the first approved pull request; fixed package counts, along with Jierong Li", profileService: "Mastodon", profileURL: URL(string: "https://elk.zone/mstdn.social/@oscb@hachyderm.io")!),
    ]

    @State private var isPackageGroupExpanded: Bool = false
    @State private var isContributorGroupExpanded: Bool = false

    var body: some View
    {
        HStack(alignment: .top, spacing: 20)
        {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 150, height: 150)
                .animation(.none)

            VStack(alignment: .leading, spacing: 20)
            {
                VStack(alignment: .leading)
                {
                    Text(NSApplication.appName!)
                        .font(.title)
                    Text("Version \(NSApplication.appVersion!) (\(NSApplication.buildVersion!))")
                        .font(.caption)
                }

                Text("© 2022 David Bureš and contributors.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack
                {
                    DisclosureGroup(isExpanded: $isPackageGroupExpanded)
                    {
                        List(usedPackages)
                        { package in
                            HStack
                            {
                                VStack(alignment: .leading)
                                {
                                    Text(package.name)
                                        .font(.headline)
                                    Text(package.whyIsItUsed)
                                        .font(.subheadline)
                                }

                                Spacer()

                                ButtonThatOpensWebsites(websiteURL: package.packageURL, buttonText: "GitHub")
                            }
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            idealHeight: 100
                        )
                    } label: {
                        Text("Packages Used")
                    }
                    .animation(.none, value: isPackageGroupExpanded)

                    DisclosureGroup
                    {
                        List
                        {
                            Section("Special Thanks")
                            {
                                ForEach(specialThanks)
                                { contributor in
                                    HStack(spacing: 10)
                                    {
                                        VStack(alignment: .leading)
                                        {
                                            Text(contributor.name)
                                                .font(.headline)
                                            Text(contributor.reasonForAcknowledgement)
                                                .font(.subheadline)
                                        }

                                        Spacer()

                                        ButtonThatOpensWebsites(websiteURL: contributor.profileURL, buttonText: contributor.profileService)
                                    }
                                }
                            }

                            Section("Acknowledged Contributors")
                            {
                                ForEach(acknowledgedContributors)
                                { contributor in
                                    HStack(spacing: 10)
                                    {
                                        VStack(alignment: .leading)
                                        {
                                            Text(contributor.name)
                                                .font(.headline)
                                            Text(contributor.reasonForAcknowledgement)
                                                .font(.subheadline)
                                        }

                                        Spacer()

                                        ButtonThatOpensWebsites(websiteURL: contributor.profileURL, buttonText: contributor.profileService)
                                    }
                                }
                            }
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            idealHeight: 200
                        )
                    } label: {
                        Text("Acknowledged Contributors")
                    }
                    .animation(.none, value: isContributorGroupExpanded)
                }

                HStack
                {
                    Button
                    {
                        NSWorkspace.shared.open(URL(string: "https://github.com/buresdv/Cork")!)
                    } label: {
                        Label("Contribute", systemImage: "curlybraces")
                    }

                    Spacer()

                    Button
                    {
                        NSWorkspace.shared.open(URL(string: "https://elk.zone/mstdn.social/@davidbures")!)
                    } label: {
                        Label("Contact Me", systemImage: "paperplane")
                    }
                }
            }
            .frame(width: 350, alignment: .topLeading)
            .animation(.none)
        }
        .padding()
    }
}

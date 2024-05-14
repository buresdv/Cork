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
    private let usedPackages: [UsedPackage] = [
        UsedPackage(
            name: "about.packages.1.name",
            whyIsItUsed: "about.packages.1.purpose",
            packageURL: URL(string: "https://github.com/buresdv/DavidFoundation")!
        ),
        UsedPackage(
            name: "about.packages.2.name",
            whyIsItUsed: "about.packages.2.purpose",
            packageURL: URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!
        ),
        UsedPackage(
            name: "about.packages.3.name",
            whyIsItUsed: "about.packages.3.purpose",
            packageURL: URL(string: "https://github.com/sindresorhus/LaunchAtLogin-Modern")!
        )
    ]

    private let specialThanks: [AcknowledgedContributor] = [
        AcknowledgedContributor(
            name: "about.thanks.1.name",
            reasonForAcknowledgement: "about.thanks.1.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/sebj")!
        ),
        AcknowledgedContributor(
            name: "about.thanks.2.name",
            reasonForAcknowledgement: "about.thanks.2-3.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/dimitribouniol")!
        ),
        AcknowledgedContributor(
            name: "about.thanks.3.name",
            reasonForAcknowledgement: "about.thanks.2-3.purpose",
            profileService: .website,
            profileURL: URL(string: "https://twos.dev")!
        )
    ]
    private let acknowledgedContributors: [AcknowledgedContributor] = [
        AcknowledgedContributor(
            name: "about.contributors.1.name",
            reasonForAcknowledgement: "about.contributors.1.purpose",
            profileService: .mastodon,
            profileURL: URL(string: "https://mastodon.social/@cocoaphony")!
        ),
        AcknowledgedContributor(
            name: "about.contributors.6.name",
            reasonForAcknowledgement: "about.contributors.6.purpose",
            profileService: .website,
            profileURL: URL(string: "https://christiantietze.de")!
        ),
        AcknowledgedContributor(
            name: "about.contributors.5.name",
            reasonForAcknowledgement: "about.contributors.5.purpose",
            profileService: .website,
            profileURL: URL(string: "https://andreyrd.com")!
        ),
        AcknowledgedContributor(
            name: "about.contributors.2.name",
            reasonForAcknowledgement: "about.contributors.2.purpose",
            profileService: .mastodon,
            profileURL: URL(string: "https://mastodon.world/@luckkerr")!
        ),
        AcknowledgedContributor(
            name: "about.contributors.3.name",
            reasonForAcknowledgement: "about.contributors.3.purpose",
            profileService: .mastodon,
            profileURL: URL(string: "https://mastodon.social/@jierongli")!
        ),
        AcknowledgedContributor(
            name: "about.contributors.4.name",
            reasonForAcknowledgement: "about.contributors.4.purpose",
            profileService: .mastodon,
            profileURL: URL(string: "https://hachyderm.io/@oscb")!
        ),
    ]
    
    private let translators: [AcknowledgedContributor] = [
        AcknowledgedContributor(
            name: "about.translator.1.name",
            reasonForAcknowledgement: "about.translator.1.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/Jerry23011")!
        ),
        AcknowledgedContributor(
            name: "about.translator.2.name",
            reasonForAcknowledgement: "about.translator.2.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/sh95014")!),
        AcknowledgedContributor(
            name: "about.translator.3.name",
            reasonForAcknowledgement: "about.translator.3.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/hecaex")!),
		AcknowledgedContributor(
			name: "about.translator.4.name",
			reasonForAcknowledgement: "about.translator.4.purpose",
			profileService: .github,
			profileURL: URL(string: "https://github.com/louchebem06")!),
        AcknowledgedContributor(
            name: "about.translator.5.name",
            reasonForAcknowledgement: "about.translator.5.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/utkinn")!),
        AcknowledgedContributor(
            name: "about.translator.6.name",
            reasonForAcknowledgement: "about.translator.6.purpose",
            profileService: .github,
            profileURL: URL(string: "https://github.com/smitt14ua")!),
    ]

    @State private var isPackageGroupExpanded: Bool = false
    @State private var isContributorGroupExpanded: Bool = false
    @State private var isTranslatorGroupExpanded: Bool = false

    var body: some View
    {
        HStack(alignment: .top, spacing: 20)
        {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 150, height: 150)
                .transaction { $0.animation = nil }

            VStack(alignment: .leading, spacing: 20)
            {
                VStack(alignment: .leading)
                {
                    Text(NSApplication.appName!)
                        .font(.title)
                    Text("about.version-\(NSApplication.appVersion!)-\(NSApplication.buildVersion!)")
                        .font(.caption)
                }

                Text("about.copyright")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading)
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
                        Text("about.packages")
                    }
                    .animation(.none, value: isPackageGroupExpanded)

                    DisclosureGroup
                    {
                        List
                        {
                            Section("about.thanks")
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

                                        ButtonThatOpensWebsites(websiteURL: contributor.profileURL, buttonText: contributor.profileService.key)
                                    }
                                }
                            }

                            Section("about.contributors")
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

                                        ButtonThatOpensWebsites(websiteURL: contributor.profileURL, buttonText: contributor.profileService.key)
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
                        Text("about.contributors")
                    }
                    .animation(.none, value: isContributorGroupExpanded)
                    
                    DisclosureGroup
                    {
                        List
                        {
                            ForEach(translators)
                            { translator in
                                HStack(spacing: 10)
                                {
                                    VStack(alignment: .leading)
                                    {
                                        Text(translator.name)
                                            .font(.headline)
                                        Text(translator.reasonForAcknowledgement)
                                            .font(.subheadline)
                                    }

                                    Spacer()

                                    ButtonThatOpensWebsites(websiteURL: translator.profileURL, buttonText: translator.profileService.key)
                                }
                            }
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            idealHeight: 150
                        )
                    } label: {
                        Text("about.translators")
                    }
                    .animation(.none, value: isTranslatorGroupExpanded)
                    
                    Text("about.privacy-policy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack
                {
                    Button
                    {
                        NSWorkspace.shared.open(URL(string: "https://github.com/buresdv/Cork")!)
                    } label: {
                        Label("about.contribute", systemImage: "curlybraces")
                    }

                    Spacer()

                    Button
                    {
                        NSWorkspace.shared.open(URL(string: "https://mstdn.social/@davidbures")!)
                    } label: {
                        Label("about.contact", systemImage: "paperplane")
                    }
                }
            }
            .frame(width: 350, alignment: .topLeading)
            .transaction { $0.animation = nil }
        }
        .padding()
        //.fixedSize()
    }
}

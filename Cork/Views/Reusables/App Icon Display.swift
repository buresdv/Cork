//
//  App Icon Display.swift
//  Cork
//
//  Created by David Bureš - P on 22.10.2025.
//

import SwiftUI

/// Show the icon of a linked app
struct AppIconDisplay: View
{
    enum DisplayType
    {
        case asIcon(
            usingApp: Application
        )
        case asIconWithAppNameDisplayed(
            usingApp: Application,
            namePosition: AppNamePosition
        )
        case asPathControl(
            usingURL: URL
        )

        enum AppNamePosition
        {
            case besideAppIcon
            case underAppIcon
        }
    }

    let displayType: DisplayType
    
    let allowRevealingInFinderFromIcon: Bool

    var body: some View
    {
        switch displayType
        {
        case .asIcon(let usingApp):
            ApplicationIconImage(
                app: usingApp,
                allowRevealingInFinderThroughIcon: allowRevealingInFinderFromIcon
            )
        case .asIconWithAppNameDisplayed(let usingApp, let namePosition):
            switch namePosition
            {
            case .besideAppIcon:
                HStack(alignment: .center, spacing: 5)
                {
                    ApplicationIconImage(
                        app: usingApp,
                        allowRevealingInFinderThroughIcon: allowRevealingInFinderFromIcon
                    )

                    applicationName(app: usingApp)
                }
            case .underAppIcon:

                VStack(alignment: .center, spacing: 5)
                {
                    ApplicationIconImage(
                        app: usingApp,
                        allowRevealingInFinderThroughIcon: allowRevealingInFinderFromIcon
                    )

                    applicationName(app: usingApp)
                }
            }
        case .asPathControl(let usingURL):
            AppIconDisplay_AsPathControl(urlToApp: usingURL)
        }
    }

    @ViewBuilder
    func applicationName(app: Application) -> some View
    {
        Text(app.name)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private struct ApplicationIconImage: View
{
    let app: Application
    
    let allowRevealingInFinderThroughIcon: Bool

    var body: some View
    {
        if let appIconImage = app.iconImage
        {
            appIconImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35)
                .contextMenu {
                    Button
                    {
                        app.url.revealInFinder(.openParentDirectoryAndHighlightTarget)
                    } label: {
                        Label("action.reveal-\(app.name)-in-finder", systemImage: "finder")
                    }
                }
        }
    }
}

private struct AppIconDisplay_AsPathControl: NSViewRepresentable
{
    typealias NSViewType = NSPathControl

    let urlToApp: URL

    func makeNSView(context _: Context) -> NSPathControl
    {
        let pathControl: NSPathControl = .init()

        pathControl.url = urlToApp

        if let lastPathItem = pathControl.pathItems.last
        {
            pathControl.pathItems = [lastPathItem]
        }

        return pathControl
    }

    func updateNSView(_: NSPathControl, context _: Context)
    {}
}

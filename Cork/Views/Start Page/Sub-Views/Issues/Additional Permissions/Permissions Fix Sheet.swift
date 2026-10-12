//
//  Permissions Fix Sheet.swift
//  Cork
//
//  Created by David Bureš - P on 17.09.2026.
//

import ApplicationInspector
import CorkModels
import CorkShared
import FactoryKit
import SwiftUI

struct PermissionsFixSheet: View
{
    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: false)
            {
                PermissionsFixSheetContent()
            }
        }
    }
}

struct PermissionsFixSheetContent: View
{
    @Injected(\.appConstants) private var appConstants: AppConstants

    @InjectedObservable(\.appState) private var appState

    private enum CorkInfoLoadingState
    {
        case loading
        case erroredOut(withError: Application.ApplicationInitializationError)
        case loaded(corkAppReference: Application)
    }

    @State private var corkInfoLoadingState: CorkInfoLoadingState = .loading

    var body: some View
    {
        VStack(alignment: .center, spacing: 10)
        {
            Text("fix-permissions.explanation.title")
                .font(.title2)
                .multilineTextAlignment(.center)

            Text("fix-permissions.explanation.body")
                .font(.caption)
                .foregroundStyle(.secondary)

            iconDisplay
        }
        .navigationTitle("fix-permissions.title")
        .toolbar
        {
            ToolbarItem(placement: .cancellationAction)
            {
                Button
                {
                    appState.dismissSheet()
                } label: {
                    Text("action.cancel")
                }
            }
        }
        .task
        {
            do throws(Application.ApplicationInitializationError)
            {
                let loadedCorkApp: Application = try await self.loadCorkAppInformation()

                self.corkInfoLoadingState = .loaded(corkAppReference: loadedCorkApp)
            }
            catch let corkAppLoadingError
            {
                appConstants.logger.error("Couldn§t load information about Cork: \(corkAppLoadingError, privacy: .public)")

                self.corkInfoLoadingState = .erroredOut(withError: corkAppLoadingError)
            }
        }
    }

    @ViewBuilder
    private var iconDisplay: some View
    {
        switch self.corkInfoLoadingState
        {
        case .loading:
            CorkAppDisplay_Loading()
        case .erroredOut(let withError):
            CorkAppDisplay_Failure(error: withError)
        case .loaded(let corkAppReference):
            CorkAppDisplay_Success(appReference: corkAppReference)
        }
    }

    private func loadCorkAppInformation() async throws(Application.ApplicationInitializationError) -> Application
    {
        return try .init(from: Bundle.main.bundleURL)
    }
}

private struct CorkAppDisplay_Success: View
{
    let appReference: Application

    var body: some View
    {
        VStack(alignment: .center, spacing: 7)
        {
            VStack(alignment: .center, spacing: 5)
            {
                Text("fix-permissions.explanation.instructions.step-1.title")
                    .font(.title3)

                // Text("fix-permissions.explanation.instructions.step-1.text")

                Button
                {
                    NSWorkspace.shared.open(.init(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
                } label: {
                    Label("action.open-full-disk-access-settings", systemImage: "hand.raised")
                }
                .labelStyle(.titleOnly)
            }

            VStack(alignment: .center, spacing: 5)
            {
                Text("fix-permissions.explanation.instructions.step-2.title")
                    .font(.title3)

                Text("fix-permissions.explanation.instructions.step-2.text")

                DraggableAppProxyIcon(app: appReference, width: 70)
                { draggingState in
                    switch draggingState
                    {
                    case .draggingStarted:
                        AppConstants.shared.logger.debug("Dragging started")

                        NSWorkspace.shared.open(.init(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
                        
                    case .draggingEnded:
                        AppConstants.shared.logger.debug("Dragging ended")
                    }
                }
            }
        }
    }
}

private struct CorkAppDisplay_Failure: View
{
    let error: Application.ApplicationInitializationError

    var body: some View
    {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

private struct CorkAppDisplay_Loading: View
{
    var body: some View
    {
        ProgressView()
    }
}

// MARK: - To make the icon draggable on older macOS, we gotta use AppKit

public struct DraggableAppProxyIcon: View
{
    let app: Application
    let width: CGFloat

    let onDraggingStateChanged: ((DraggingState) -> Void)?

    public enum DraggingState
    {
        case draggingStarted
        case draggingEnded
    }

    public init(
        app: Application,
        width: CGFloat,
        onDraggingStateChanged: ((DraggingState) -> Void)? = nil
    )
    {
        self.app = app
        self.width = width
        self.onDraggingStateChanged = onDraggingStateChanged
    }

    @State private var isIconRaised: Bool = false

    public var body: some View
    {
        DraggableAppProxyIconInternal(app: app, width: width, onDraggingStateChanged: onDraggingStateChanged)
            .offset(y: isIconRaised ? -4 : 0)
            .onAppear
            {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true))
                {
                    isIconRaised = true
                }
            }
    }
}

private struct DraggableAppProxyIconInternal: NSViewRepresentable
{
    typealias NSViewType = AppProxyIconView

    let app: Application
    let width: CGFloat

    let onDraggingStateChanged: ((DraggableAppProxyIcon.DraggingState) -> Void)?

    func makeNSView(context _: Context) -> AppProxyIconView
    {
        AppProxyIconView(app: app, width: width)
    }

    func updateNSView(_ nsView: AppProxyIconView, context _: Context)
    {
        nsView.app = app
        nsView.iconWidth = width
        nsView.onDraggingStateChanged = onDraggingStateChanged
    }
}

private final class AppProxyIconView: NSView, NSDraggingSource
{
    var app: Application
    {
        didSet
        { /// Has to be written like this, or the icon can't be seen
            updateIcon()
        }
    }

    var iconWidth: CGFloat
    {
        didSet
        { /// Has to be written like this, or the icon can't be seen
            invalidateIntrinsicContentSize()
        }
    }

    var onDraggingStateChanged: ((DraggableAppProxyIcon.DraggingState) -> Void)?

    private let imageView: NSImageView = .init()

    init(
        app: Application,
        width: CGFloat,
        onDraggingStateChanged: ((DraggableAppProxyIcon.DraggingState) -> Void)? = nil
    )
    {
        self.app = app
        self.iconWidth = width

        self.onDraggingStateChanged = onDraggingStateChanged

        super.init(frame: .init(x: 0, y: 0, width: width, height: width))

        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.frame = bounds
        imageView.autoresizingMask = [.width, .height]

        addSubview(imageView)

        updateIcon()

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    /// Make the sheet not freak the fuck out every time there's an update
    override var intrinsicContentSize: NSSize
    {
        .init(width: iconWidth, height: iconWidth)
    }

    private func updateIcon()
    {
        if let iconPath = app.iconPath, let iconImage = NSImage(contentsOf: iconPath)
        {
            imageView.image = iconImage
        }
        else
        {
            imageView.image = NSWorkspace.shared.icon(forFile: app.url.path)
        }
    }

    override func mouseDown(with event: NSEvent)
    {
        let draggingItem: NSDraggingItem = .init(pasteboardWriter: app.url as NSURL)
        draggingItem.setDraggingFrame(bounds, contents: imageView.image)

        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }

    func draggingSession(
        _: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation
    {
        switch context
        {
        case .withinApplication:
            return []
        case .outsideApplication:
            return [.copy]
        @unknown default:
            return [.copy]
        }
    }

    func draggingSession(
        _: NSDraggingSession,
        willBeginAt _: NSPoint
    )
    {
        onDraggingStateChanged?(.draggingStarted)
    }

    func draggingSession(
        _: NSDraggingSession,
        endedAt _: NSPoint,
        operation _: NSDragOperation
    )
    {
        onDraggingStateChanged?(.draggingEnded)
    }
}

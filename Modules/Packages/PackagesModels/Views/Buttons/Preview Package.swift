//
//  Preview Package.swift
//  Cork
//
//  Created by David Bureš on 16.09.2024.
//

import SwiftUI
import CorkShared
import ButtonKit

/// Preview a package according to its name
public struct PreviewPackageButton: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    public init(packageToPreview: MinimalHomebrewPackage) {
        
        self.packageToPreview = packageToPreview
        
    }
    
    public let packageToPreview: MinimalHomebrewPackage
    
    public var body: some View
    {
        Button
        {
                 
            openWindow(value: packageToPreview)
        } label: {
            Label("preview-package.action", systemImage: "scope")
        }
        .keyboardShortcut("p", modifiers: [.command, .option])
    }
}

public struct PreviewPackageButtonWithCustomAction: View
{
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public let action: () -> Void
    public var body: some View {
        Button
        {
            action()
        } label: {
            Label("preview-package.action", systemImage: "scope")
        }
        .keyboardShortcut("p", modifiers: [.command, .option])
    }
}

public struct PreviewPackageButtonWithCustomLabel: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    public init(label: LocalizedStringKey, packageToPreview: MinimalHomebrewPackage) {
        self.label = label
        self.packageToPreview = packageToPreview
    }
    
    public let label: LocalizedStringKey
    
    public let packageToPreview: MinimalHomebrewPackage
    
    public var body: some View
    {
        Button
        {
            openWindow(value: packageToPreview)
        } label: {
            Label(label, systemImage: "scope")
        }
        .keyboardShortcut("p", modifiers: [.command, .option])
    }
}

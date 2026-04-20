//
//  View - Implemented & Unimplemented Error Row.swift
//  Cork
//
//  Created by David Bureš - P on 18.04.2026.
//

import Foundation
import SwiftUI

public extension View
{
    
    /// Row for an unimplemented error - provides a row with a button for inspecting the error that occured
    /// - Parameters:
    ///   - rowText: Text which is displayed in the row
    ///   - rawTerminalOutput: Terminal output, which gets displayed in the error inspector
    /// - Returns: Row for the unimplemented error
    @ViewBuilder
    func unimplementedErrorRow(
        rowView: some View,
        rawTerminalOutput: String?,
        openWindowAction: OpenWindowAction
    ) -> some View
    {
        HStack
        {
            rowView

            Spacer()

            Button
            {
                openWindowAction(id: .errorInspectorWindowID, value: rawTerminalOutput)
            } label: {
                Label("action.inspect-error", systemImage: "info.circle")
            }
            .labelStyle(.iconOnly)
        }
    }
    
    /// Row for implemented error - provides a row with a caption containing loclaized description of the error that occured
    /// - Parameters:
    ///   - rowView: Main text of the row - Can be a package name, etc.
    ///   - error: Error to display
    /// - Returns: Row for the implemented error
    @ViewBuilder
    func implementedErrorRow(
        rowView: some View,
        error: any LocalizedError
    ) -> some View
    {
        VStack(alignment: .leading, spacing: 2)
        {
            rowView
                .font(.body)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.multicolor)
        }
    }
}

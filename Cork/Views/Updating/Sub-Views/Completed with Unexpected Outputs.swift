//
//  Completed with Unexpected Outputs State.swift
//  Cork
//
//  Created by David Bureš - P on 26.04.2026.
//

import SwiftUI
import CorkTerminalFunctions

struct CompletedwithUnexpectedOutputsStage: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    let unexpectedOutputs: [TerminalOutput]
    
    var body: some View
    {
        ComplexWithIcon(systemName: "seal")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "update-packages.unexpected-outputs.title",
                    subheadline: "update-packages.unexpected-outputs.message",
                    alignment: .leading
                )

                DisclosureGroup("update-packages.unexpected-outputs.details-dropdown.label")
                {
                    List(unexpectedOutputs)
                    { unexpectedOutput in
                        unexpectedOutput.outputView
                    }
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                    .frame(minHeight: 100)
                }
            }
        }
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
            }
        }
    }
}

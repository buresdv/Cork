//
//  Mass Adoption Stage - Failure.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import SwiftUI

struct MassAdoptionStage_Failure: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    @Environment(MassAppAdoptionView.MassAppAdoptionTacker.self) var massAppAdoptionTracker: MassAppAdoptionView.MassAppAdoptionTacker
    
    var body: some View
    {
        ComplexWithIcon(systemName: "seal")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "mass-adoption.some-failed",
                    subheadline: "mass-adoption.some-failed.message",
                    alignment: .leading
                )
                
                AdoptionResultsList()
            }
        }
    }
}

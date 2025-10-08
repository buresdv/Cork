//
//  Mass Adoption Stage - Some Success Some Failure.swift
//  Cork
//
//  Created by David Bureš - P on 08.10.2025.
//

import SwiftUI

struct MassAdoptionStage_SomeSuccessSomeFailure: View
{
    @Environment(MassAppAdoptionView.MassAppAdoptionTacker.self) var massAppAdoptionTracker: MassAppAdoptionView.MassAppAdoptionTacker
    
    var body: some View
    {
        ComplexWithIcon(systemName: "xmark.seal")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "mass-adoption.failed",
                    subheadline: "mass-adoption.failed.message",
                    alignment: .leading
                )
                
                AdoptionResultsList()
            }
        }
    }
}

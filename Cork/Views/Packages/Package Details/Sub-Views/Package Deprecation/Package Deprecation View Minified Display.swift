//
//  Package Deprecation View Minified Display.swift
//  Cork
//
//  Created by David Bureš - P on 08.06.2025.
//

import CorkShared
import Defaults
import SwiftUI

struct PackageDeprecationViewMinifiedDisplay: View
{
    @Default(.caveatDisplayOptions) var caveatDisplayOptions: PackageCaveatDisplay

    let isDeprecated: Bool

    let deprecationReason: String?

    @State private var isShowingDeprecationReason: Bool = false

    var outlinedPillText: LocalizedStringKey
    {
        if deprecationReason == nil
        {
            // TODO: Replace the inline SF symbol with a reference
            return "package-details.deprecation.notice.minified.no-reason-for-deprecation-provided"
        }
        else
        {
            // TODO: Replace the inline SF symbol with a reference
            return "package-details.deprecation.notice.minified.reason-for-deprecation-provided"
        }
    }

    var body: some View
    {
        if isDeprecated
        {
            if caveatDisplayOptions == .mini
            {
                OutlinedPillText(text: outlinedPillText, color: .orange)
                    .onTapGesture
                    {
                        isShowingDeprecationReason = true
                    }
                    .modify
                    { viewProxy in
                        if let deprecationReason
                        {
                            viewProxy
                                .popover(isPresented: $isShowingDeprecationReason)
                                {
                                    Text(deprecationReason)
                                }
                        }
                        else
                        {
                            viewProxy
                        }
                    }
            }
        }
    }
}

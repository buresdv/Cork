//
//  Package Deprecation View.swift
//  Cork
//
//  Created by David Bureš - P on 01.06.2025.
//

import SwiftUI

struct PackageDeprecationViewFullDisplay: View
{
    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full
    
    let isDeprecated: Bool

    let deprecationReason: String?

    var body: some View
    {
        if isDeprecated
        {
            if caveatDisplayOptions == .full
            {
                HStack(alignment: .top, spacing: 10)
                {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.orange)

                    if let deprecationReason
                    {
                        PackageDeprecatedWithReason(deprecationReason: deprecationReason)
                    }
                    else
                    {
                        PackageDeprecatedNoReasonProvided()
                    }
                }
            }
        }
    }
}

private struct PackageDeprecatedNoReasonProvided: View
{
    var body: some View
    {
        Text("package-details.deprecation.notice")
    }
}

private struct PackageDeprecatedWithReason: View
{
    let deprecationReason: String

    var body: some View
    {
        VStack(alignment: .leading, spacing: 7)
        {
            Text("package-details.deprecation.notice")
            
            Divider()
            
            Text(deprecationReason)
        }
    }
}

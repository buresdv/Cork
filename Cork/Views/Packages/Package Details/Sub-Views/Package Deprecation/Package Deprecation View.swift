//
//  Package Deprecation View.swift
//  Cork
//
//  Created by David Bureš - P on 01.06.2025.
//

import SwiftUI

struct PackageDeprecationView: View
{
    let isDeprecated: Bool
    
    let deprecationReason: String?
    
    var body: some View
    {
        if !isDeprecated
        {
            VStack(alignment: .center)
            {
                Text("package-details.deprecation.notice")
                
                if let deprecationReason
                {
                    Text(deprecationReason)
                }
            }
        }
    }
}

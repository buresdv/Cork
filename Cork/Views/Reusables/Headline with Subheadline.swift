//
//  Headline with Subheadline.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct HeadlineWithSubheadline: View
{
    let headline: LocalizedStringKey
    let subheadline: LocalizedStringKey

    let alignment: HorizontalAlignment

    var body: some View
    {
        VStack(alignment: alignment)
        {
            Text(headline)
                .font(.headline)
            Text(subheadline)
        }
    }
}

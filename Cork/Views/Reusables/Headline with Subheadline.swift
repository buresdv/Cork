//
//  Headline with Subheadline.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct HeadlineWithSubheadline: View
{
    @State var headline: LocalizedStringKey
    @State var subheadline: LocalizedStringKey

    @State var alignment: HorizontalAlignment

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

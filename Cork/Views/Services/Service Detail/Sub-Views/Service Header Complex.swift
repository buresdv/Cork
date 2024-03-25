//
//  Service Header Complex.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import SwiftUI

struct ServiceHeaderComplex: View
{
    
    let service: HomebrewService
    
    var body: some View
    {
        Section
        {
            LabeledContent
            {
                Text(service.status.displayableName)
            } label: {
                Text("service.status.label")
            }
        } header: {
            Text(service.name)
                .font(.title)
        }
    }
}

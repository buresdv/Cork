//
//  Sidebar Service Row.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

struct SidebarServiceRow: View
{
    let service: HomebrewService

    var body: some View
    {
        NavigationLink(value: NavigationTargetServices.service(service)) {
            Text(service.name)
        }
        .contextMenu
        {
            Button
            {
                service.revealInFinder()
            } label: {
                Text("action.reveal-in-finder")
            }
        }
    }
}

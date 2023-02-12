//
//  Acknowledged Contributor.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation

struct AcknowledgedContributor: Identifiable
{
    var id: UUID = .init()

    let name: String
    let reasonForAcknowledgement: String
    let profileService: String
    let profileURL: URL
}

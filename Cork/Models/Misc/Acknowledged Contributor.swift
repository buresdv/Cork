//
//  Acknowledged Contributor.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation
import SwiftUI

struct AcknowledgedContributor: Identifiable
{
    var id: UUID = .init()

    let name: LocalizedStringKey
    let reasonForAcknowledgement: LocalizedStringKey
    let profileService: ProfileService
    let profileURL: URL

    enum ProfileService
    {
        case github, mastodon, website

        var key: LocalizedStringKey
        {
            switch self
            {
            case .github: return "about.contributor.service.github"
            case .mastodon: return "about.contributor.service.mastodon"
            case .website: return "about.contributor.service.website"
            }
        }
    }
}

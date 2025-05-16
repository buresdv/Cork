//
//  Day Spans.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI
import Defaults

public enum DiscoverabilityDaySpans: Int, Hashable, Identifiable, CaseIterable, Defaults.Serializable
{
    public var id: Self
    {
        self
    }

    case month = 30
    case quarterYear = 90
    case year = 365

    public var key: LocalizedStringKey
    {
        switch self
        {
        case .month:
            return "settings.discoverability.time-span.month"
        case .quarterYear:
            return "settings.discoverability.time-span.quarter-year"
        case .year:
            return "settings.discoverability.time-span.year"
        }
    }
}

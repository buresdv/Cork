//
//  Day Spans.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI

enum DiscoverabilityDaySpans: Int, Hashable, Identifiable, CaseIterable
{
    var id: Self { self }
    
    case oneDay = 1
    case week = 7
    case month = 30
    
    var key: LocalizedStringKey
    {
        switch self {
            case .oneDay:
                return "settings.discoverability.time-span.today"
            case .week:
                return "settings.discoverability.time-span.week"
            case .month:
                return "settings.discoverability.time-span.month"
        }
    }
}

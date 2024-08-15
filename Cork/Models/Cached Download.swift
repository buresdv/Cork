//
//  Cached Download.swift
//  Cork
//
//  Created by David Bureš on 04.11.2023.
//

import Charts
import Foundation
import SwiftUI

struct CachedDownload: Identifiable, Hashable
{
    var id: UUID = .init()

    let packageName: String
    let sizeInBytes: Int

    var packageType: CachedDownloadType?
}

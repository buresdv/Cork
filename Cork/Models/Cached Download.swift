//
//  Cached Download.swift
//  Cork
//
//  Created by David Bureš on 04.11.2023.
//

import Foundation

struct CachedDownload: Identifiable, Hashable
{
    var id: String { packageName }

    let packageName: String
    let sizeInBytes: Int
}

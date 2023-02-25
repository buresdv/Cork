//
//  Int64 - Convert Sirectory Size to Presentable Format.swift
//  Cork
//
//  Created by David Bureš on 25.02.2023.
//

import Foundation

extension Int64
{
    func convertDirectorySizeToPresentableFormat(size: Int64) -> String
    {
        let byteFormatter = ByteCountFormatter()
        
        return byteFormatter.string(fromByteCount: size)
    }
}

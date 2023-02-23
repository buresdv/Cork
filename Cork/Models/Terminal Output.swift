//
//  Terminal Output.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import Foundation

struct TerminalOutput
{
    var standardOutput: String
    var standardError: String
}

enum StreamedTerminalOutput
{
    case standardOutput(String)
    case standardError(String)
}

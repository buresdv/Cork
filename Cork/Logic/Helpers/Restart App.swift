//
//  Restart App.swift
//  Cork
//
//  Created by David Bureš on 22.03.2023.
//

import Foundation

func restartApp()
{
    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
    {
        let url: URL = .init(fileURLWithPath: Bundle.main.resourcePath!)
        let path: String = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task: Process = .init()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
}

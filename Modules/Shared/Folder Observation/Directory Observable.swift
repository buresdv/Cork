//
//  DirectoryObservable.swift
//  MetaNotes
//
//  Created by Daniel Saidi on 2021-04-17.
//  Copyright © 2021-2025 Daniel Saidi. All rights reserved.
//
//  Original implementation:
//  https://medium.com/over-engineering/monitoring-a-folder-for-changes-in-ios-dc3f8614f902
//

import Combine
import SwiftUI

/// This class can observe file system changes for a folder.
///
/// The view uses an internal ``DirectoryMonitor`` instance,
/// to keep the ``files`` property in sync.
@MainActor
public class DirectoryObservable: ObservableObject {
    
    /// Create an instance that observes the provided `url`.
    ///
    /// - Parameters:
    ///   - url: The directory URL to observe.
    ///   - fileManager: The file manager to use, by default `.default`.
    public init(
        url: URL,
        fileManager: FileManager = .default
    ) {
        self.url = url
        self.fileManager = fileManager
        folderMonitor.startMonitoringChanges()
        self.handleChanges()
    }
    
    @Published
    public var files: [URL] = []
    
    private let url: URL
    private let fileManager: FileManager
    
    private lazy var folderMonitor = DirectoryMonitor(
        url: url,
        onChange: {
            self.handleChanges()
        }
    )

    private func handleChanges() {
        let files = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: .producesRelativePathURLs)
        
        DispatchQueue.main.async {
            self.files = files ?? []
        }
    }
}

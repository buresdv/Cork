//
//  Downloader.swift
//  Cork
//
//  Created by David Bureš - P on 20.09.2026.
//

import BetterProgress
import Foundation

public actor Downloader: NSObject, URLSessionDelegate, URLSessionTaskDelegate
{
    @MainActor public var progress: Progress = .init(totalItems: 100, aboveProgressBarText: nil, underProgressBarText: nil)

    private var activeDownload: Task<URL, Error>?

    public func downloadFile(from url: URL) async throws -> URL
    {
        let downloadTask = Task<URL, Error>
        {
            try await URLSession.shared.download(from: url, delegate: self).0
        }

        activeDownload = downloadTask

        defer
        {
            activeDownload = nil
        }

        return try await withTaskCancellationHandler
        {
            try await downloadTask.value
        }
        onCancel:
        {
            downloadTask.cancel()
        }
    }

    public func urlSession(
        _: URLSession,
        downloadTask _: URLSessionDownloadTask,
        didWriteData _: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async
    {
        guard totalBytesExpectedToWrite > 0 else { return }

        let fractionCompleted: Double = .init(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        await MainActor.run
        {
            progress.completedUnitCount = Int64(fractionCompleted * Double(progress.totalUnitCount))
        }
    }

    public nonisolated func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo _: URL)
    {
        // Intentionally left empty
    }

    public func cancel()
    {
        activeDownload?.cancel()
    }
}

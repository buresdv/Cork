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
    @MainActor var progress: Progress = .init(totalItems: 100, aboveProgressBarText: nil, underProgressBarText: nil)

    func downloadFile(from url: URL) async throws -> URL
    {
        let (downloadURL, response) = try await URLSession.shared.download(
            from: url, delegate: self
        )

        return downloadURL
    }

    func urlSession(
        _: URLSession,
        downloadTask _: URLSessionDownloadTask,
        didWriteData _: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64) async
    {
        Task
        {
            await MainActor.run
            {
                progress.increment(byPercentage: Double(totalBytesWritten / totalBytesExpectedToWrite))
            }
        }
    }

    nonisolated func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo _: URL)
    {
        // Intentionally left empty
    }
}

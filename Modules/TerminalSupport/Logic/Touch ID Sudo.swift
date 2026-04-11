//
//  Touch ID Sudo.swift
//  Cork
//
//  Created by Dávid Balatoni on 11.04.2026.
//

import Foundation
import CorkShared

/// Checks whether Touch ID for sudo is configured on this system by inspecting PAM configuration.
///
/// macOS uses `/etc/pam.d/sudo_local` (preferred, user-editable) and `/etc/pam.d/sudo`
/// for sudo authentication. If `pam_tid.so` appears as a `sufficient` auth module,
/// Touch ID can be used for sudo authentication.
public func isTouchIDSudoEnabled() -> Bool
{
    let pamPaths: [String] = [
        "/etc/pam.d/sudo_local",
        "/etc/pam.d/sudo"
    ]

    for path in pamPaths
    {
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8)
        else
        {
            continue
        }

        let lines = contents.components(separatedBy: .newlines)
        for line in lines
        {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            /// Skip comments and empty lines
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#")
            else
            {
                continue
            }

            if trimmed.contains("pam_tid.so")
            {
                AppConstants.shared.logger.info("Touch ID for sudo is enabled (found pam_tid.so in \(path))")
                return true
            }
        }
    }

    AppConstants.shared.logger.info("Touch ID for sudo is not configured")
    return false
}

/// Creates a pseudo-terminal pair for use with processes that need a TTY.
///
/// When Touch ID for sudo is enabled, `sudo` must go through PAM's interactive auth
/// (not `SUDO_ASKPASS`), which requires a terminal. This creates a PTY pair so the
/// child process sees a real terminal on its stdin.
///
/// - Returns: A tuple of (master file handle, slave file handle), or `nil` if allocation fails.
///   The caller is responsible for closing both file descriptors when done.
public func createPseudoTerminal() -> (master: FileHandle, slave: FileHandle)?
{
    let master: Int32 = posix_openpt(O_RDWR | O_NOCTTY)
    guard master >= 0
    else
    {
        AppConstants.shared.logger.warning("Failed to open pseudo-terminal master")
        return nil
    }

    guard grantpt(master) == 0
    else
    {
        AppConstants.shared.logger.warning("Failed to grant pseudo-terminal")
        close(master)
        return nil
    }

    guard unlockpt(master) == 0
    else
    {
        AppConstants.shared.logger.warning("Failed to unlock pseudo-terminal")
        close(master)
        return nil
    }

    guard let slavePath = ptsname(master)
    else
    {
        AppConstants.shared.logger.warning("Failed to get pseudo-terminal slave path")
        close(master)
        return nil
    }

    let slave: Int32 = open(slavePath, O_RDWR)
    guard slave >= 0
    else
    {
        AppConstants.shared.logger.warning("Failed to open pseudo-terminal slave")
        close(master)
        return nil
    }

    return (
        master: FileHandle(fileDescriptor: master, closeOnDealloc: true),
        slave: FileHandle(fileDescriptor: slave, closeOnDealloc: true)
    )
}

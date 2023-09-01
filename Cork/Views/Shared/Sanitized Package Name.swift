//
//  Sanitized Package Name.swift
//  Cork
//
//  Created by David Bureš on 01.09.2023.
//

import SwiftUI

/// Package name that contains only the name of the package, not its version in the `package@version` format
struct SanitizedPackageName: View
{
    let packageName: String

    var body: some View
    {
        if packageName.contains("@")
        { /// Only do the matching if the name contains @
            if let sanitizedName = try? regexMatch(from: packageName, regex: ".+?(?=@)")
            { /// Try to REGEX-match the name out of the raw name
                Text(sanitizedName)
            }
            else
            { /// If the REGEX matching fails, just show "Failure"
                Text("FAILURE")
            }
        }
        else
        { /// If the name doesn't contain the @, don't do anything
            Text(packageName)
        }
    }
}

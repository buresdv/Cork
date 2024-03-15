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
    @State var shouldShowVersion: Bool
    
    var packageNameWithoutTapName: String
    {
        if packageName.contains("/")
        { /// Check if the package name contains slashes (this would mean it includes the tap name)
            if let sanitizedName = try? regexMatch(from: packageName, regex: "[^\\/]*$")
            {
                return sanitizedName
            }
            else
            {
                return packageName
            }
        }
        else
        {
            return packageName
        }
    }

    var body: some View
    {
        if packageNameWithoutTapName.contains("@")
        { /// Only do the matching if the name contains @
            if let sanitizedName = try? regexMatch(from: packageNameWithoutTapName, regex: ".+?(?=@)")
            { /// Try to REGEX-match the name out of the raw name
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(sanitizedName)
                    
                    if shouldShowVersion
                    {
                        /// The version is the length of the package name, + 1 due to the @ character
                        Text("v. \(String(packageNameWithoutTapName.dropFirst(sanitizedName.count + 1)))")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
            }
            else
            { /// If the REGEX matching fails, just show the entire name
                Text(packageNameWithoutTapName)
            }
        }
        else
        { /// If the name doesn't contain the @, don't do anything
            Text(packageNameWithoutTapName)
        }
    }
}

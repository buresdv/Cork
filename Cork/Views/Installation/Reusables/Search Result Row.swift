//
//  Search Result Row.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI
import CorkShared

struct SearchResultRow: View, Sendable
{
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false
    @AppStorage("showCompatibilityWarning") var showCompatibilityWarning: Bool = true

    @EnvironmentObject var brewData: BrewDataStorage

    let searchedForPackage: BrewPackage
    let context: Self.Context
    
    @State private var description: String?
    @State private var isCompatible: Bool?

    @State private var isLoadingDescription: Bool = true
    @State private var descriptionParsingFailed: Bool = false
    
    @State private var selectedVersion: String = ""
    
    var packageHasMultipleInstallableVersion: Bool
    {
        if searchedForPackage.versions.count > 1
        {
            return true
        }
        else
        {
            return false
        }
    }

    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack(alignment: .center)
            {
                
                SanitizedPackageName(packageName: searchedForPackage.name, shouldShowVersion: packageHasMultipleInstallableVersion ? false : true)
                
                if packageHasMultipleInstallableVersion
                {
                    Picker(selection: $selectedVersion) {
                        ForEach(searchedForPackage.versions, id: \.self)
                        { packageVersion in
                            Text(packageVersion)
                        }
                    } label: {
                        EmptyView()
                    }
                    .labelsHidden()
                    .controlSize(.small)
                    .fixedSize(horizontal: true, vertical: true)
                    .onAppear
                    {
                        self.selectedVersion = searchedForPackage.versions.first!
                    }
                }
                else
                {
                    Text(searchedForPackage.versions.formatted(.list(type: .and)))
                }

                switch context
                {
                case .topPackages:
                    Spacer()
                    
                    if let downloadCount = searchedForPackage.downloadCount
                    {
                        Text("add-package.top-packages.list-item-\(downloadCount)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                case .searchResults:
                    if searchedForPackage.type == .formula
                    {
                        if brewData.successfullyLoadedFormulae.contains(where: { $0.name == searchedForPackage.name })
                        {
                            PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                        }
                    }
                    else
                    {
                        if brewData.successfullyLoadedCasks.contains(where: { $0.name == searchedForPackage.name })
                        {
                            PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                        }
                    }
                    
                    if let isCompatible
                    {
                        if !isCompatible
                        {
                            if showCompatibilityWarning
                            {
                                Image(systemName: "exclamationmark.circle")
                                Text("add-package.result.not-optimized-for-\(AppConstants.shared.osVersionString.fullName)")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }

            if showDescriptionsInSearchResults
            {
                if !descriptionParsingFailed
                { // Show this if the description got properly parsed
                    if isLoadingDescription
                    {
                        Text("add-package.result.loading-description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    else
                    {
                        if let description
                        {
                            Text(description)
                                .font(.caption)
                        }
                        else
                        {
                            NoDescriptionProvidedView()
                        }
                    }
                }
                else
                { // Otherwise, tell the user the parsing failed
                    Text("add-package.result.loading-failed")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .tag(searchedForPackage)
        .task
        {
            if showDescriptionsInSearchResults
            {
                AppConstants.shared.logger.info("\(searchedForPackage.name, privacy: .auto) came into view")

                if description == nil
                {
                    defer
                    {
                        isLoadingDescription = false
                    }

                    AppConstants.shared.logger.info("\(searchedForPackage.name, privacy: .auto) does not have its description loaded")

                    do
                    {
                        let searchedForPackage: BrewPackage = .init(name: searchedForPackage.name, type: searchedForPackage.type, installedOn: Date(), versions: [], sizeInBytes: nil, downloadCount: nil)

                        do
                        {
                            let parsedPackageInfo: BrewPackageDetails = try await searchedForPackage.loadDetails()

                            description = parsedPackageInfo.description

                            isCompatible = parsedPackageInfo.isCompatible
                        }
                        catch let descriptionParsingError
                        { // This happens when a package doesn' have any description at all, hence why we don't display an error
                            AppConstants.shared.logger.error("Failed while parsing searched-for package info: \(descriptionParsingError.localizedDescription, privacy: .public)")

                            descriptionParsingFailed = true
                        }
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("\(searchedForPackage.name, privacy: .auto) already has its description loaded")
                }
            }
        }
    }
    
    enum Context {
        case searchResults
        case topPackages
    }
}

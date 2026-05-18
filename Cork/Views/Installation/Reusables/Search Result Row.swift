//
//  Search Result Row.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import CorkModels
import CorkShared
import Defaults
import SwiftUI

struct SearchResultRow: View, Sendable
{
    @Default(.showDescriptionsInSearchResults) var showDescriptionsInSearchResults: Bool
    @Default(.showCompatibilityWarning) var showCompatibilityWarning: Bool

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let searchedForPackage: BrewPackage
    let context: Self.Context

    enum PackageDescriptionLoadingState: Equatable
    {
        case loading
        case loaded(withResult: String)
        case failed(withError: BrewPackage.DescriptionLoadingError)
    }

    @State private var packageDescriptionLoadingState: PackageDescriptionLoadingState = .loading

    @State private var isLoadingDescription: Bool = true
    @State private var descriptionParsingFailed: Bool = false

    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack(alignment: .center)
            {
                searchedForPackage.nameView(withComponents: .boundVersion)

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
                        if brewPackagesTracker.successfullyLoadedFormulae.contains(where: { $0.getCompletePackageName() == searchedForPackage.getCompletePackageName() })
                        {
                            PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                        }
                    }
                    else
                    {
                        if brewPackagesTracker.successfullyLoadedCasks.contains(where: { $0.getCompletePackageName() == searchedForPackage.getCompletePackageName() })
                        {
                            PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                        }
                    }

                    /*
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
                      */
                }
            }

            if showDescriptionsInSearchResults
            {
                switch packageDescriptionLoadingState
                {
                case .loading:
                    Text("add-package.result.loading-description")
                        .font(.caption)
                        .foregroundColor(.secondary)
                case .loaded(let result):
                    Text(result)
                        .font(.caption)
                case .failed(let withError):
                    switch withError
                    {
                    case .packageHasNoDescription:
                        NoDescriptionProvidedView()
                    case .outputHasUnexpectedFormat(let rawOutput):
                        Text(rawOutput.description)
                            .foregroundStyle(.orange)
                    case .unexpectedNumberOfOutputs(let outputs):
                        Text("add-package.result.description.too-many-outputs.label")
                            .foregroundStyle(.orange)
                        
                        List(outputs)
                        { rawOutput in
                            Text(rawOutput.description)
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        .frame(minHeight: 100)
                        .layoutPriority(10)

                    case .regexConstructionFailed:
                        Text(withError.localizedDescription)
                    }
                }
            }
        }
        .tag(searchedForPackage)
        .task
        {
            if showDescriptionsInSearchResults
            {
                AppConstants.shared.logger.info("\(searchedForPackage.name(withPrecision: .precise), privacy: .auto) came into view")

                if self.packageDescriptionLoadingState == .loading
                {
                    AppConstants.shared.logger.info("\(searchedForPackage.name(withPrecision: .precise), privacy: .auto) does not have its description loaded")

                    do
                    {
                        let searchedForPackage: BrewPackage = .init(
                            rawName: searchedForPackage.name(withPrecision: .precise),
                            type: searchedForPackage.type,
                            installedOn: Date(),
                            versions: [],
                            url: nil,
                            sizeInBytes: nil,
                            downloadCount: nil
                        )

                        do throws(BrewPackage.DescriptionLoadingError)
                        {
                            // let parsedPackageInfo: BrewPackage.BrewPackageDetails = try await searchedForPackage.loadDetails()

                            let loadedDescription: String = try await searchedForPackage.loadDescripton()

                            self.packageDescriptionLoadingState = .loaded(withResult: loadedDescription)

                            // isCompatible = parsedPackageInfo.isCompatible
                        }
                        catch let descriptionParsingError
                        {
                            self.packageDescriptionLoadingState = .failed(withError: descriptionParsingError)
                        }
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("\(searchedForPackage.name(withPrecision: .precise), privacy: .auto) already has its description loaded")
                }
            }
        }
    }

    enum Context
    {
        case searchResults
        case topPackages
    }
}

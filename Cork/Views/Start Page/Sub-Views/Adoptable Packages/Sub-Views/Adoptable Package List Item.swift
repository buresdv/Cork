//
//  Adoptable Package List Item.swift
//  Cork
//
//  Created by David Bureš - P on 22.12.2025.
//

import ButtonKit
import CorkModels
import CorkShared
import SwiftUI
import SwiftData

struct AdoptablePackageListItem: View
{
    enum ExclusionButtonType
    {
        case excludeOnly, includeOnly, none
    }

    enum AdoptionCandidatesDisplayType
    {
        case oneAdoptionCandidate(
            adoptionCandidate: BrewPackagesTracker.AdoptableApp.AdoptionCandidate
        )

        case multipleAdoptionCandidates(
            adoptionCandidates: [BrewPackagesTracker.AdoptableApp.AdoptionCandidate],
            selectedAdoptionCandidate: BrewPackagesTracker.AdoptableApp.AdoptionCandidate?
        )
    }

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let adoptableCask: BrewPackagesTracker.AdoptableApp
    
    var isAdoptableCaskDisabled: Bool
    {
        return self.excludedApps.contains
        { excludedApp in
            return excludedApp.appExecutable == adoptableCask.appExecutable
        }
    }

    let exclusionButtonType: ExclusionButtonType
    
    @Query private var excludedApps: [ExcludedAdoptableApp]

    /// Retrieve the correct number of adoption candidates for this adoptable app
    var adoptionCandidateDisplayType: AdoptionCandidatesDisplayType
    {
        if adoptableCask.adoptionCandidates.count == 1, let singleAdoptionCandidate = adoptableCask.adoptionCandidates.first
        {
            return .oneAdoptionCandidate(adoptionCandidate: singleAdoptionCandidate)
        }
        else
        {
            return .multipleAdoptionCandidates(
                adoptionCandidates: adoptableCask.adoptionCandidates,
                selectedAdoptionCandidate: adoptableCask.selectedAdoptionCandidate
            )
        }
    }

    var body: some View
    {
        HStack(alignment: .center, spacing: 5)
        {
            if let app = adoptableCask.app
            {
                AppIconDisplay(
                    displayType: .asIcon(usingApp: app),
                    allowRevealingInFinderFromIcon: false
                )
            }

            VStack(alignment: .leading, spacing: 2)
            {
                switch adoptionCandidateDisplayType
                {
                case .oneAdoptionCandidate(let adoptionCandidate):
                    adoptionCandidateInfo_onlyOneAdoptionCandidate(adoptionCandidate: adoptionCandidate)
                case .multipleAdoptionCandidates(let adoptionCandidates, _):
                    adoptionCandidatesInfo_multipleAdoptionCandidates(adoptionCandidates: adoptionCandidates)
                }
            }
        }
        .contextMenu
        {
            switch adoptionCandidateDisplayType
            {
            case .oneAdoptionCandidate(let adoptionCandidate):
                PreviewPackageButtonWithCustomLabel(
                    label: "action.preview-package-app-would-be-adopted-as.\(adoptionCandidate.caskName)", packageToPreview: .init(name: adoptionCandidate.caskName, type: .cask, installedIntentionally: true)
                )

            case .multipleAdoptionCandidates(_, let selectedAdoptionCandidate):
                if let selectedAdoptionCandidate
                {
                    PreviewPackageButtonWithCustomLabel(
                        label: "action.preview-package-app-would-be-adopted-as.\(selectedAdoptionCandidate.caskName)", packageToPreview: .init(name: selectedAdoptionCandidate.caskName, type: .cask, installedIntentionally: true)
                    )
                }
                else
                {
                    Text("error.preview-package-app-would-be-adopted-as.no-cask-name-selected")
                        .disabled(true)
                }
            }

            Button
            {
                adoptableCask.fullAppUrl.revealInFinder(.openParentDirectoryAndHighlightTarget)
            } label: {
                Label("action.reveal-\(adoptableCask.appExecutable)-in-finder", systemImage: "finder")
            }

            Divider()

            switch exclusionButtonType
            {
            case .excludeOnly:
                ignoreAdoptableAppButton(appToIgnore: adoptableCask)
            case .includeOnly:
                includeAdoptableAppButton(appToInclude: adoptableCask)
            case .none:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    func adoptionCandidateInfo_onlyOneAdoptionCandidate(
        adoptionCandidate: BrewPackagesTracker.AdoptableApp.AdoptionCandidate
    ) -> some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            VStack(alignment: .leading, spacing: 4)
            {
                Text(adoptableCask.appExecutable)

                if let caskDescription = adoptionCandidate.caskDescription
                {
                    Text(caskDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("(\(adoptionCandidate.caskName))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    func adoptionCandidatesInfo_multipleAdoptionCandidates(
        adoptionCandidates: [BrewPackagesTracker.AdoptableApp.AdoptionCandidate]
    ) -> some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 5)
        {
            VStack(alignment: .leading, spacing: 4)
            {
                Text(adoptableCask.appExecutable)

                if let caskDescription = adoptionCandidates.filter(\.isSelectedForAdoption).first?.caskDescription
                {
                    Text(caskDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Picker("", selection: Binding(
                get: {
                    adoptionCandidates.first { $0.isSelectedForAdoption }
                },
                set: { newSelectedCandidate in
                    guard let newSelectedCandidate = newSelectedCandidate
                    else
                    {
                        appState.showAlert(
                            errorToShow: .generic(
                                customMessage: String(localized: "mass-adoption.failed.details-dropdown.missing-candidate-cask-name")
                            )
                        )
                        
                        return
                    }

                    // Deselect all candidates, then select the new one
                    for candidate in adoptionCandidates
                    {
                        candidate.isSelectedForAdoption = (candidate.id == newSelectedCandidate.id)
                    }
                }
            ))
            {
                ForEach(adoptionCandidates)
                { adoptionCandidate in
                    VStack(alignment: .leading, spacing: 4)
                    {
                        Text(adoptionCandidate.caskName)

                        if let caskDescription = adoptionCandidate.caskDescription
                        {
                            Text(caskDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tag(adoptionCandidate)
                }
            }
            .pickerStyle(.automatic)
            .fixedSize()
            .disabled(isAdoptableCaskDisabled)
        }
    }

    @ViewBuilder
    func ignoreAdoptableAppButton(appToIgnore: BrewPackagesTracker.AdoptableApp) -> some View
    {
        AsyncButton
        {
            AppConstants.shared.logger.info("Adding app \(appToIgnore.appExecutable) to the excluded apps")

            await appToIgnore.excludeSelf()
        } label: {
            Label("action.package-adoption.ignore.\(appToIgnore.appExecutable)", systemImage: "xmark.circle")
        }
    }

    @ViewBuilder
    func includeAdoptableAppButton(appToInclude: BrewPackagesTracker.AdoptableApp) -> some View
    {
        AsyncButton
        {
            AppConstants.shared.logger.info("Removing app \(appToInclude.appExecutable) from the excluded apps")

            await appToInclude.includeSelf()
        } label: {
            Label("action.package-adoption.include.\(appToInclude.appExecutable)", systemImage: "plus.circle")
        }
    }
}

//
//  Onboarding Defaults Slider.swift
//  Cork
//
//  Created by David Bureš on 21.10.2023.
//

import SwiftUI

enum SetupLevels: Identifiable, CaseIterable
{
    case basic, slightlyBasic, medium, slightlyAdvanced, advanced
    
    var id: Self { self }
    
    var name: LocalizedStringKey
    {
        switch self {
            case .basic:
                return "setup.level.basic.title"
            case .slightlyBasic:
                return "setup.level.slightly-basic.title"
                
            case .medium:
                return "setup.level.medium.title"
                
            case .slightlyAdvanced:
                return "setup.level.slightly-advanced.title"
                
            case .advanced:
                return "setup.level.advanced.title"
        }
    }
}

struct OnboardingDefaultsSlider: View {
    
    @Binding var setupLevel: SetupLevels
    @Binding var sliderValue: Float
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 5, content: {
            Text("setup.slider.title")
                .font(.title2)
            
            SubtitleText(text: "onboarding.settings.exmplanation")
            
            Slider(value: $sliderValue, in: 0...4, step: 1) {
                //Text("setup.slider.title")
            } minimumValueLabel: {
                Text("setup.level.basic.title")
            } maximumValueLabel: {
                Text("setup.level.advanced.title")
            }
            .onChange(of: sliderValue) {newValue in
                AppConstants.logger.debug("New slider value: \(sliderValue, privacy: .public)")
                if sliderValue == 0
                {
                    setupLevel = .basic
                }
                else if sliderValue == 1
                {
                    setupLevel = .slightlyBasic
                }
                else if sliderValue == 2
                {
                    setupLevel = .medium
                }
                else if sliderValue == 3
                {
                    setupLevel = .slightlyAdvanced
                }
                else
                {
                    setupLevel = .advanced
                }
                
                AppConstants.logger.debug("\(String(describing: setupLevel.name.stringValue()))")
            }
        })
    }
}

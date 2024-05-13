//
//  WalkthroughViewModel.swift
//  Penny Pockets
//
//  Created by Mostafa Alaa on 13/05/2024.
//

import Foundation
import Combine

fileprivate let storiesData = [OnBoardingModel(asset: DesignSystem.Icons.Onboarding.onboardingFirst, screenTitle: "Gain total control of your money", screenSubtitle: "Become your own money manager and make every cent count")
                       , OnBoardingModel(asset: DesignSystem.Icons.Onboarding.onboardingSecond, screenTitle: "Know where your money goes", screenSubtitle: "Track your transaction easily, with categories and financial report ")
                       , OnBoardingModel(asset: DesignSystem.Icons.Onboarding.onboardingThird, screenTitle: "Planning ahead", screenSubtitle: "Setup your budget for each category so you in control")]
class OnboardingViewModel {
    @Published var currentStoryIndex: Int
    @Published var currentStory: OnBoardingModel?

    var storiesEnded: Bool {
        return currentStoryIndex == storiesData.count-1
    }
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.currentStoryIndex = 0
        self.currentStory = storiesData[0]
        $currentStoryIndex
            .map { index in
                storiesData[index]
            }
            .assign(to: \.currentStory, on: self)
            .store(in: &cancellables)
    }
}

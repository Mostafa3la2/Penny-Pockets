//
//  Assets.swift
//  Penny Pockets
//
//  Created by Mostafa Alaa on 13/05/2024.
//

import Foundation
import UIKit
protocol DesignSystemAssetsProtocol {
    var image: UIImage? { get }
    var imageName: String { get }
}
extension DesignSystemAssetsProtocol {
    var image: UIImage? {
        return UIImage(named: self.imageName)
    }
}
extension DesignSystem {
    enum Icons {
        enum Onboarding: DesignSystemAssetsProtocol {
            var imageName: String {
                return "\(self)"
            }

            // cases must match asset name
            case onboardingFirst
            case onboardingSecond
            case onboardingThird
        }
    }
}

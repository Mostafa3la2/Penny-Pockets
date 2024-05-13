//
//  OnboardingModels.swift
//  Penny Pockets
//
//  Created by Mostafa Alaa on 13/05/2024.
//

import Foundation
import UIKit

struct OnBoardingModel {
    var screenTitle: String?
    var screenSubtitle: String?
    var asset: UIImage?

    init(asset: DesignSystemAssetsProtocol?, screenTitle: String? = nil, screenSubtitle: String? = nil, image: UIImage? = nil) {
        self.screenTitle = screenTitle
        self.screenSubtitle = screenSubtitle
        self.asset = asset?.image
    }
}

//
//  UINavigationController+.swift
//  Pixl
//
//  Created by Dscyre Scotti on 26/04/2021.
//

import UIKit

extension UINavigationController {
    func setTransparency() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    func removeTransparency() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
        navigationBar.isTranslucent = false
    }
    
//    func customizeBackBarButtonItem() {
//        let customImage = UIImage(systemName: "chevron.left.circle.fill")
//        navigationBar.backIndicatorImage = customImage
//        navigationBar.backIndicatorTransitionMaskImage = customImage
//    }
}


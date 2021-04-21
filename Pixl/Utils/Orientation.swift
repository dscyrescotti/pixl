//
//  Orientation.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit

struct Orientation {
    static var isLandscape: Bool {
        get {
            return UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isLandscape : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)!
        }
    }
    
    static var isPortrait: Bool {
        get {
            return UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isPortrait : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait)!
        }
    }
    
    static func `if`<T>(portrait: T, landscape: T) -> T {
        isPortrait ? portrait : landscape
    }
}

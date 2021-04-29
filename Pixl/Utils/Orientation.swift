//
//  Orientation.swift
//  Pixl
//
//  Created by Dscyre Scotti on 29/04/2021.
//

import UIKit

enum Orientation {
    case landscape
    case portrait
}

extension Orientation {
    func value<T>(portrait: T, landscape: T) -> T {
        switch self {
        case .portrait: return portrait
        case .landscape: return landscape
        }
    }
}

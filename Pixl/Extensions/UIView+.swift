//
//  UIView+.swift
//  Pixl
//
//  Created by Dscyre Scotti on 22/04/2021.
//

import Foundation
import UIKit

extension UIView {
    var isLandscape: Bool {
        view.frame.width > view.frame.height
    }
    func orientation<T>(portrait: T, landscape: T) -> T {
        isLandscape ? landscape : portrait
    }
}

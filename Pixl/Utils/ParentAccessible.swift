//
//  ParentAccessible.swift
//  Pixl
//
//  Created by Dscyre Scotti on 03/05/2021.
//

import UIKit

protocol ParentAccessible: AnyObject {
    var parentView: UIView! { get set }
}

//
//  Bindable.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Foundation
import UIKit

protocol Bindable: AnyObject {
    associatedtype ViewModel
    var viewModel: ViewModel! { get set }
    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    func bind(_ viewModel: Self.ViewModel) {
        self.viewModel = viewModel
        self.loadViewIfNeeded()
        self.bindViewModel()
    }
}

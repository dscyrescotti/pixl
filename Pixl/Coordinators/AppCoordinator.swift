//
//  AppCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 23/04/2021.
//

import UIKit
import XCoordinator

class AppCoordinator {
    let window: UIWindow
    private var coordinator: Presentable?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if true && false {
            coordinator = HomeCoordinator().strongRouter
        } else {
            coordinator = AuthCoordinator().strongRouter
        }
        coordinator?.setRoot(for: window)
    }
}

//
//  AppCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 23/04/2021.
//

import UIKit
import XCoordinator

enum AppRoute {
    case home
    case auth
}

class AppCoordinator {
    let window: UIWindow
    private var coordinator: Presentable?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        coordinator = presenter(.auth)
        coordinator?.setRoot(for: window)
    }
    
    func trigger(for route: AppRoute) {
        let coordinator = presenter(route)
        coordinator.viewController.view.alpha = 0
        window.rootViewController = coordinator.viewController
        UIView.animate(withDuration: 0.2) {
            coordinator.viewController.view.alpha = 1
        }
    }
    
    private func presenter(_ route: AppRoute) -> Presentable {
        switch route {
        case .home:
            return HomeCoordinator(self).strongRouter
        case .auth:
            return AuthCoordinator(self).strongRouter
        }
    }
}

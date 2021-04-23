//
//  HomeCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Foundation
import XCoordinator
import UIKit

enum HomeRoute: Route {
    case main
    case settings
    case logout
}

class HomeCoordinator: NavigationCoordinator<HomeRoute> {
    init() {
        super.init(initialRoute: .main)
        rootViewController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationBar.tintColor = .label
        rootViewController.view.backgroundColor = .systemBackground
    }
    
    override func prepareTransition(for route: HomeRoute) -> NavigationTransition {
        switch route {
        case .main:
            let coordinator = MainCoordinator(unownedRouter)
            return .push(coordinator)
        case .settings:
            let settingsViewController = SettingsViewController()
            return .push(settingsViewController)
        case .logout:
            let coordinator = AuthCoordinator()
            coordinator.rootViewController.modalPresentationStyle = .fullScreen
            coordinator.rootViewController.modalTransitionStyle = .crossDissolve
            return .presentOnRoot(coordinator.strongRouter)
        }
    }
}

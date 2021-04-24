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
    case photo(id: String)
}

class HomeCoordinator: NavigationCoordinator<HomeRoute> {
    
    weak var parent: AppCoordinator?
    
    init(_ parent: AppCoordinator? = nil) {
        self.parent = parent
        super.init(initialRoute: .main)
        rootViewController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationBar.tintColor = .label
        rootViewController.navigationBar.barTintColor = .systemBackground
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
            parent?.trigger(.auth)
            return .none()
        case .photo:
            let photoDetailsViewController = PhotoDetailsViewController()
            return .push(photoDetailsViewController)
        }
    }
}

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
    case search
    case logout
    case photo(PhotoRoute)
    case collection(CollectionRoute)
    case profile
}

class HomeCoordinator: NavigationCoordinator<HomeRoute> {
    
    weak var parent: AppCoordinator?
    
    init(_ parent: AppCoordinator? = nil) {
        self.parent = parent
        super.init(initialRoute: .main)
        rootViewController.navigationBar.prefersLargeTitles = false
        rootViewController.navigationBar.tintColor = .label
        rootViewController.setTransparency()
    }
    
    override func prepareTransition(for route: HomeRoute) -> NavigationTransition {
        switch route {
        case .main:
            let coordinator = MainCoordinator(unownedRouter)
            return .push(coordinator)
        case .settings:
            let settingsViewController = SettingsViewController()
            settingsViewController.router = unownedRouter
            settingsViewController.bind()
            return .push(settingsViewController)
        case .search:
            let coordinator = SearchCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(SearchRoute.search, on: coordinator)
        case .logout:
            parent?.trigger(.login)
            return .none()
        case let .photo(photoRoute):
            let coordinator = PhotoCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(photoRoute, on: coordinator)
        case let .collection(collectionRoute):
            let coordinator = CollectionCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(collectionRoute, on: coordinator)
        case .profile:
            let coordinator = UserCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return  .trigger(UserRoute.me, on: coordinator)
        }
    }
}

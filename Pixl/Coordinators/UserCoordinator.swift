//
//  UserCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import XCoordinator
import UIKit

indirect enum UserRoute: Route {
    case details(user: User)
    case photo(PhotoRoute)
    case collection(CollectionRoute)
    case me
}

class UserCoordinator: NavigationCoordinator<UserRoute> {
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: nil)
    }
    
    override func prepareTransition(for route: UserRoute) -> NavigationTransition {
        switch route {
        case let .details(user):
            let userViewController = UserViewController()
            let userViewModel = UserViewModel(.username(user.username), router: unownedRouter)
            userViewController.bind(userViewModel)
            userViewController.title = user.username
            return .push(userViewController)
        case let .photo(photoRoute):
            let coordinator = PhotoCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(photoRoute, on: coordinator)
        case let .collection(collectionRoute):
            let coordinator = CollectionCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(collectionRoute, on: coordinator)
        case .me:
            let userViewController = UserViewController()
            let userViewModel = UserViewModel(.me, router: unownedRouter)
            userViewController.bind(userViewModel)
            return .push(userViewController)
        }
    }
    
}

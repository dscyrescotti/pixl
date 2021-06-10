//
//  CollectionCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import XCoordinator
import UIKit

enum CollectionRoute: Route {
    case details(collection: PhotoCollection)
    case photo(PhotoRoute)
    case user(UserRoute)
}

class CollectionCoordinator: NavigationCoordinator<CollectionRoute> {
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: nil)
    }
    
    override func prepareTransition(for route: CollectionRoute) -> NavigationTransition {
        switch route {
        case let .details(collection):
            let collectionViewController = CollectionViewController()
            collectionViewController.title = collection.title
            let collectionViewModel = CollectionViewModel(unownedRouter, collection: collection)
            collectionViewController.bind(collectionViewModel)
            return .push(collectionViewController)
        case let .photo(photoRoute):
            let coordinator = PhotoCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(photoRoute, on: coordinator)
        case let .user(userRoute):
            let coordinator = UserCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(userRoute, on: coordinator)
        }
    }
    
}

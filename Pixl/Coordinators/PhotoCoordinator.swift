//
//  PhotoCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 24/04/2021.
//

import XCoordinator
import UIKit

enum PhotoRoute: Route {
    case details(photo: Photo)
    case user(UserRoute)
}

class PhotoCoordinator: NavigationCoordinator<PhotoRoute> {
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: nil)
    }
    
    override func prepareTransition(for route: PhotoRoute) -> NavigationTransition {
        switch route {
        case let .details(photo):
            let photoViewController = PhotoViewController(color: UIColor(photo.color))
            let photoViewModel = PhotoViewModel(unownedRouter, photo: photo)
            photoViewController.bind(photoViewModel)
            return .push(photoViewController)
        case let .user(userRoute):
            let coordinator = UserCoordinator(rootViewController: rootViewController)
            addChild(coordinator)
            return .trigger(userRoute, on: coordinator)
        }
    }
    
}



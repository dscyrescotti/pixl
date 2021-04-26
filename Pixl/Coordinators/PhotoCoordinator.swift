//
//  PhotoCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 24/04/2021.
//

import XCoordinator

enum PhotoRoute: Route {
    case details(photo: Photo)
    case user(id: String)
}

class PhotoCoordinator: NavigationCoordinator<PhotoRoute> {
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: nil)
    }
    
    override func prepareTransition(for route: PhotoRoute) -> NavigationTransition {
        switch route {
        case let .details(photo):
            let photoViewController = PhotoViewController()
            let photoViewModel = PhotoViewModel(unownedRouter, photo: photo)
            photoViewController.bind(photoViewModel)
//            rootViewController.setTransparency()
            return .push(photoViewController)
        case .user:
            let userViewController = UserViewController()
            return .push(userViewController)
        }
    }
    
}



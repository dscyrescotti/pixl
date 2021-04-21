//
//  MainCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Foundation
import XCoordinator
import UIKit

enum MainRoute: Route {
    case photos
    case collections
}

class MainCoordinator: TabBarCoordinator<MainRoute> {
    
    init(_ router: UnownedRouter<HomeRoute>) {
        let photosViewController = PhotosViewController()
        photosViewController.bind(PhotosViewModel(router))
        photosViewController.tabBarItem = .init(title: "Photos", image: UIImage(systemName: "photo.on.rectangle.angled"), tag: 0)
        
        let collectionsViewController = CollectionsViewController()
        collectionsViewController.tabBarItem = .init(title: "Collections", image: UIImage(systemName: "rectangle.3.offgrid"), tag: 1)
        
        let vc = MainViewController()
        let viewModel = MainViewModel(router)
        vc.bind(viewModel)
        
        super.init(rootViewController: vc, tabs: [photosViewController, collectionsViewController], select: 0)
    }
    
    override func prepareTransition(for route: MainRoute) -> TabBarTransition {
        switch route {
        case .photos:
            return .select(index: 0)
        case .collections:
            return .select(index: 1)
        }
    }
}

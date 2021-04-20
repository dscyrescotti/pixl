//
//  AppCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 20/04/2021.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = .init()
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}

//
//  AppCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import XCoordinator

enum AppRoute: Route {
    case login
    case home
}

class AppCoordinator: NavigationCoordinator<AppRoute> {

    init() {
        super.init(initialRoute: .home)
        rootViewController.navigationBar.prefersLargeTitles = true
    }
    
    override func prepareTransition(for route: RouteType) -> NavigationTransition {
        switch route {
        case .login:
            let viewModel = LoginViewModel(unownedRouter)
            let loginViewController = LoginViewController()
            loginViewController.bind(viewModel)
            return .push(loginViewController)
        case .home:
            let coordinator = HomeCoordinator()
            coordinator.rootViewController.modalPresentationStyle = .fullScreen
            return .presentOnRoot(coordinator.strongRouter)
        }
    }
    
}

//
//  AuthCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import XCoordinator

enum AppRoute: Route {
    case login
    case home
}

class AuthCoordinator: NavigationCoordinator<AppRoute> {

    init() {
        super.init(initialRoute: .login)
        rootViewController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationBar.tintColor = .label
        rootViewController.view.backgroundColor = .systemBackground
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
            coordinator.rootViewController.modalTransitionStyle = .crossDissolve
            return .presentOnRoot(coordinator.strongRouter)
        }
    }
    
}

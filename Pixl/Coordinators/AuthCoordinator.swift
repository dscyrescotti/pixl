//
//  AuthCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import XCoordinator

enum AuthRoute: Route {
    case login
    case home
}

class AuthCoordinator: NavigationCoordinator<AuthRoute> {
    
    weak var parent: AppCoordinator?

    init(_ parent: AppCoordinator? = nil) {
        self.parent = parent
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
            parent?.trigger(for: .home)
            return .none()
        }
    }
    
}

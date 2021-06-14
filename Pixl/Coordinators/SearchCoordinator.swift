//
//  SearchCoordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 14/06/2021.
//

import UIKit
import XCoordinator

enum SearchRoute: Route {
    case search
    case topic(topic: Topic)
}

class SearchCoordinator: NavigationCoordinator<SearchRoute> {
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: nil)
    }
    
    override func prepareTransition(for route: SearchRoute) -> NavigationTransition {
        switch route {
        case .search:
            let searchViewController = SearchViewController()
            let searchViewModel = SearchViewModel(router: unownedRouter)
            searchViewController.bind(searchViewModel)
            return .push(searchViewController)
        case let .topic(topic):
            let topicViewController = TopicViewController()
            topicViewController.title = topic.title
            let topicViewModel = TopicViewModel()
            topicViewController.bind(topicViewModel)
            return .push(topicViewController)
        }
    }
    
}


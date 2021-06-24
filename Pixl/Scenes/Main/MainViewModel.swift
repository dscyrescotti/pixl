//
//  MainViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Foundation
import XCoordinator
import Action

class MainViewModel {
    
    private(set) lazy var searchTrigger = searchAction.inputs
    private(set) lazy var profileTrigger = profileAction.inputs
    
    private lazy var searchAction = CocoaAction { [unowned self] in
        self.router.rx.trigger(.search)
    }
    
    private lazy var profileAction = CocoaAction { [unowned self] in
        self.router.rx.trigger(.profile)
    }
    
    let router: UnownedRouter<HomeRoute>
    
    init(_ router: UnownedRouter<HomeRoute>) {
        self.router = router
    }
}

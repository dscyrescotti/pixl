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
    private(set) lazy var settingTrigger = settingAction.inputs
    
    private lazy var searchAction = CocoaAction { [unowned self] in
        self.router.rx.trigger(.search)
    }
    
    private lazy var settingAction = CocoaAction { [unowned self] in
        self.router.rx.trigger(.settings)
    }
    
    let router: UnownedRouter<HomeRoute>
    
    init(_ router: UnownedRouter<HomeRoute>) {
        self.router = router
    }
}

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
    
    private(set) lazy var settingsTrigger = settingsAction.inputs
    
    private lazy var settingsAction = CocoaAction { [unowned self] in
        self.router.rx.trigger(.settings)
    }
    
    let router: UnownedRouter<HomeRoute>
    
    init(_ router: UnownedRouter<HomeRoute>) {
        self.router = router
    }
}

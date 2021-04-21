//
//  LoginViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Action
import RxSwift
import RxCocoa
import XCoordinator
import XCoordinatorRx

class LoginViewModel {
    private(set) lazy var loginTrigger = loginAction.inputs
    
    private lazy var loginAction = CocoaAction { [unowned self] in
        self.router.rx.trigger(.home)
    }
    
    private let router: UnownedRouter<AppRoute>
    
    init(_ router: UnownedRouter<AppRoute>) {
        self.router = router
    }
}

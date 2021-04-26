//
//  UserViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 26/04/2021.
//

import UIKit
import Then

class UserViewController: UIViewController, AppBarInjectable {
    internal var appBar = AppBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
}

extension UserViewController {
    func setUp() {
        view.backgroundColor = .systemPink
        navigationItem.largeTitleDisplayMode = .never
        
        addAppBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerLayout()
    }
}

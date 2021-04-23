//
//  MainViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import RxSwift


class MainViewController: UITabBarController, Bindable {
    
    var viewModel: MainViewModel!
    
    let barButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "gear")
    }
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }

    func bindViewModel() {
        barButton.rx.tap
            .bind(to: viewModel.settingsTrigger)
            .disposed(by: bag)
    }
}

extension MainViewController {
    func setUp() {
        title = "pixl"
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = barButton
    }
}

//
//  MainViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UITabBarController, Bindable, AppBarInjectable {
    
    var viewModel: MainViewModel!
    
    private let searchButton = BarButton(systemName: "magnifyingglass").then {
        $0.configure(with: .systemBackground)
    }
    private let settingButton = BarButton(systemName: "gear").then {
        $0.configure(with: .systemBackground)
    }
    lazy var orientationChange = PublishRelay<Orientation>()
    
    internal var appBar = AppBar()
    
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }

    func bindViewModel() {
        searchButton.rx.tap
            .bind(to: viewModel.searchTrigger)
            .disposed(by: bag)
        
        settingButton.rx.tap
            .bind(to: viewModel.settingTrigger)
            .disposed(by: bag)
        
        let orientation = orientationChange
            .distinctUntilChanged()
        
        orientation
            .bind(to: searchButton.orientationChange)
            .disposed(by: bag)
        orientation
            .bind(to: settingButton.orientationChange)
            .disposed(by: bag)
    }
}

extension MainViewController {
    func setUp() {
        title = "pixl"
        
        view.backgroundColor = .systemBackground
        tabBar.barTintColor = .systemBackground
        tabBar.tintColor = .label
        
        addAppBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange.accept(size.orientation(portrait: Orientation.portrait, landscape: .landscape))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpBarButtons()
    }
    
    func setUpBarButtons() {
        orientationChange.accept(view.orientation(portrait: Orientation.portrait, landscape: .landscape))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingButton)
    }
}


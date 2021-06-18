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
        
        let orientation = orientationChange
            .distinctUntilChanged()
        
        orientation
            .bind(to: searchButton.orientationChange)
            .disposed(by: bag)
    }
}

extension MainViewController {
    func setUp() {
        title = "pixl"
        
        view.backgroundColor = .systemBackground
        tabBar.barTintColor = .systemBackground
        tabBar.tintColor = .label
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(logout))
        
        addAppBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerLayout()
    }
    
    @objc func logout() {
        viewModel.router.trigger(.logout)
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
    }
}


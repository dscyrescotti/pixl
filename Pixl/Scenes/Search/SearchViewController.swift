//
//  SearchViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 12/06/2021.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController, Bindable, AppBarInjectable {
    var viewModel: SearchViewModel!
    
    internal var appBar: AppBar = .init()
    private let backButton = BarButton(systemName: "arrow.backward")
    lazy var orientationChange = PublishRelay<Orientation>()
    private let bag = DisposeBag()
    
    let searchController = UISearchController().then {
        $0.hidesNavigationBarDuringPresentation = false
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.placeholder = "Search free high-resolution photos"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        addAppBar()
    }
    
    func bindViewModel() {
        let orientation = orientationChange
            .distinctUntilChanged()
        
        orientation
            .bind(to: backButton.orientationChange)
            .disposed(by: bag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
        searchController.searchBar.rx.textDidEndEditing
            .flatMap { [unowned self] _ -> Observable<String> in
                guard let query = searchController.searchBar.text else {
                    return Observable.empty()
                }
                return Observable.just(query)
            }
            .subscribe(onNext: { query in
                print(query)
            })
            .disposed(by: bag)
    }
    
}

extension SearchViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}

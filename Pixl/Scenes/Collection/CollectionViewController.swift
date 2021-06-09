//
//  CollectionViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionViewController: UIViewController, Bindable, AppBarInjectable {
    internal var appBar: AppBar = .init()
    private let backButton = BarButton(systemName: "arrow.backward")
    lazy var orientationChange = PublishRelay<Orientation>()
    
    private let bag = DisposeBag()
    
    var viewModel: CollectionViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
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
    }

}

extension CollectionViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}

//
//  UserViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 26/04/2021.
//

import UIKit
import Then
import RxSwift
import RxCocoa
import SegementSlide

class UserViewController: SegementSlideDefaultViewController, Bindable, AppBarInjectable {
    internal var appBar = AppBar()
    
    var viewModel: UserViewModel!
    private let bag = DisposeBag()
    
    private let profileHeader = UserProfileHeader().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    override func segementSlideHeaderView() -> UIView? {
        return profileHeader
    }
    
    override var titlesInSwitcher: [String] {
        return ["Photos", "Collections", "Likes"]
    }
    
    override var switcherConfig: SegementSlideDefaultSwitcherConfig {
        var config = super.switcherConfig
        config.type = .tab
        config.indicatorWidth = 100
        return config
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return getChildController(index)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSelectedIndex = 0
        reloadData()
        
        setUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerLayout()
        reloadSwitcher()
    }
    
    func bindViewModel() {
        viewModel.user
            .skip(1)
            .bind(to: profileHeader.user)
            .disposed(by: bag)
    }
}

extension UserViewController {
    func setUp() {
        view.backgroundColor = .systemPink
        navigationItem.largeTitleDisplayMode = .never
        
        addAppBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Warning")
    }
    
    func registerLayout() {
        if let frame = navigationController?.navigationBar.frame {
            appBar.frame = .init(x: 0, y: -(frame.origin.y + frame.height), width: view.frame.width, height: frame.origin.y + frame.height)
        }
    }
    
    func getChildController(_ index: Int) -> SegementSlideContentScrollViewDelegate {
        switch index {
        case 0:
            let controller = UserPhotosViewController()
            controller.parentView = self.view
            let viewModel = UserPhotosViewModel(username: self.viewModel.user.value.username)
            controller.bind(viewModel)
            return controller
        case 2:
            let controller = UserPhotosViewController()
            controller.parentView = self.view
            let viewModel = UserPhotosViewModel(username: self.viewModel.user.value.username, type: .likes)
            controller.bind(viewModel)
            return controller
        default:
            return ContentViewController()
        }
    }
}

class ContentViewController: UICollectionViewController, SegementSlideContentScrollViewDelegate, WaterfallLayoutDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.cellPadding = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc var scrollView: UIScrollView {
        return collectionView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemIndigo
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        150
    }
    
}

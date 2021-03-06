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
    private let backButton = BarButton(systemName: "arrow.backward")
    lazy var orientationChange = PublishRelay<Orientation>()
    
    var viewModel: UserViewModel!
    private let bag = DisposeBag()
    var isFollowed = false {
        didSet {
            profileHeader.change(label: isFollowed ? "Following" : "Follow")
        }
    }
    
    private let profileHeader = UserProfileHeader().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.constraint(equalToConstant: 160).isActive = true
    }
    
    override func segementSlideHeaderView() -> UIView? {
        profileHeader.configure(with: viewModel.isMe)
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        reloadSwitcher()
        reloadHeader()
        // ignore warnings
        contentView.snp.removeConstraints()
        contentView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(switcherView.snp.bottom)
            make.bottom.equalTo(view)
        }
    }
    
    func bindViewModel() {
        viewModel.user
            .compactMap { $0 }
            .bind(to: profileHeader.user)
            .disposed(by: bag)
        
        viewModel.user
            .compactMap { $0 }
            .subscribe(onNext: { [unowned self] user in
                isFollowed = user.followedByUser
                title = user.username
                reloadContent()
            })
            .disposed(by: bag)
        
        profileHeader.followButton.rx.tap
            .flatMap { [unowned self] _ -> Observable<Void> in
                guard let user = viewModel.user.value else {
                    return Observable.empty()
                }
                isFollowed.toggle()
                return APIService.shared.followUser(username: user.username, isFollowed: user.followedByUser)
            }
            .asSingle()
            .subscribe()
            .disposed(by: bag)
        
        let orientation = orientationChange
            .distinctUntilChanged()
        
        orientation
            .bind(to: backButton.orientationChange)
            .disposed(by: bag)
        
        orientation
            .subscribe(onNext: { [unowned self] _ in
                selectItem(at: 0, animated: false)
            })
            .disposed(by: bag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange.accept(size.orientation(portrait: Orientation.portrait, landscape: .landscape))
    }
    
    func getChildController(_ index: Int) -> SegementSlideContentScrollViewDelegate {
        switch index {
        case 0:
            let controller = UserPhotosViewController()
            controller.parentView = self.view
            let viewModel = UserPhotosViewModel(username: self.viewModel.user.value?.username, router: self.viewModel.router)
            controller.bind(viewModel)
            return controller
        case 1:
            let controller = UserCollectionsViewController()
            controller.parentView = self.view
            let viewModel = UserCollectionsViewModel(username: self.viewModel.user.value?.username, router: self.viewModel.router)
            controller.bind(viewModel)
            return controller
        case 2:
            let controller = UserPhotosViewController()
            controller.parentView = self.view
            let viewModel = UserPhotosViewModel(username: self.viewModel.user.value?.username, type: .likes, router: self.viewModel.router)
            controller.bind(viewModel)
            return controller
        default:
            fatalError()
        }
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

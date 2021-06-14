//
//  SearchViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 12/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: UIViewController, Bindable, AppBarInjectable {
    var viewModel: SearchViewModel!
    
    internal var appBar: AppBar = .init()
    private let backButton = BarButton(systemName: "arrow.backward")
    lazy var orientationChange = PublishRelay<Orientation>()
    private let bag = DisposeBag()
    
    var topicCollectionView: UICollectionView!
    
    let searchController = UISearchController().then {
        $0.hidesNavigationBarDuringPresentation = false
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.placeholder = "Search free high-resolution photos"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        setUpTopicCollectionView()
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
        
        viewModel.topics
            .bind(to: topicCollectionView.rx.items(cellIdentifier: TopicCell.identifier, cellType: TopicCell.self)) { row, topic, cell in
                cell.placeholder(with: topic)
            }
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
        
        topicCollectionView.rx.willDisplayCell
            .bind(to: viewModel.willDisplayCell)
            .disposed(by: bag)
        
        topicCollectionView.rx.itemSelected
            .bind(to: viewModel.selectedItem)
            .disposed(by: bag)
    }
    
}

extension SearchViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    func setUpTopicCollectionView() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        
        topicCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        topicCollectionView.register(TopicCell.self, forCellWithReuseIdentifier: TopicCell.identifier)
        topicCollectionView.backgroundColor = .systemBackground
        
        view.addSubview(topicCollectionView)
    }
    
    private func sectionProvider(id: Int, environment: NSCollectionLayoutEnvironment) -> Optional<NSCollectionLayoutSection> {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(170)), subitem: item, count: view.orientation(portrait: 2, landscape: 3))
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        return section
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        registerLayout()
        
        topicCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(view)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(appBar.snp_bottomMargin)
        }
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

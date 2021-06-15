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
    
    var resultCollectionView: UICollectionView!
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<Void, SearchResult>>(configureCell: { (datasource, collectionView, indexPath, result) in
        switch result {
        case let .photo(photo):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
            cell.placeholder(with: photo)
            return cell
        case let .collection(collection):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCell.identifier, for: indexPath) as! CollectionCell
            cell.placeholder(with: collection)
            return cell
        }
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        setUpTopicCollectionView()
        setUpResultCollectionView()
        addAppBar()
    }
    
    func bindViewModel() {
        dataSource.configureSupplementaryView = { datasource, collectionView, kind, indexPath -> UICollectionReusableView in
            let result = datasource.sectionModels[indexPath.section]
            print(result)
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ResultSectionHeader.identifier, for: indexPath) as! ResultSectionHeader
            return header
        }
        
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
        
        viewModel.results
            .map { results -> [SectionModel<Void, SearchResult>] in
                return results.map { SectionModel(model: (), items: $0.results) }
            }
            .bind(to: resultCollectionView.rx.items(dataSource: dataSource))
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
            .bind(to: viewModel.searchTrigger)
            .disposed(by: bag)
        
        searchController.searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [unowned self] in
                resultCollectionView.alpha = 1
            })
            .disposed(by: bag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [unowned self] in
                resultCollectionView.alpha = 0
                resultCollectionView.scrollsToTop = true
                viewModel.results.accept([])
            })
            .disposed(by: bag)
        
        topicCollectionView.rx.willDisplayCell
            .bind(to: viewModel.willDisplayCell)
            .disposed(by: bag)
        
        resultCollectionView.rx.willDisplayCell
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
    
    func setUpResultCollectionView() {
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        
        resultCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        resultCollectionView.contentInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        resultCollectionView.backgroundColor = .systemBackground
        resultCollectionView.alpha = 0
        
        resultCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        resultCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.identifier)
        resultCollectionView.register(ResultSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ResultSectionHeader.identifier)
        
        view.addSubview(resultCollectionView)
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
        
        resultCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(topicCollectionView)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Warning")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = resultCollectionView.collectionViewLayout as? WaterfallLayout else { return }
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        layout.invalidateLayout()
    }
}

extension SearchViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let result = viewModel.results.value[indexPath.section].results[indexPath.item]
        switch result {
        case .collection:
            return 250
        case .photo(let photo):
            return photo.size(for: withWidth).height
        }
    }
    
    func collectionView(collectionView: UICollectionView, sizeForSectionHeaderViewForSection section: Int) -> CGSize {
        .init(width: view.bounds.width, height: 50)
    }
}

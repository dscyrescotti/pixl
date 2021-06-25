//
//  ResultViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 18/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ResultViewController: UIViewController, Bindable, AppBarInjectable {
    internal var appBar: AppBar = .init()
    private let backButton = BarButton(systemName: "arrow.backward")
    lazy var orientationChange = PublishRelay<Orientation>()
    
    private let bag = DisposeBag()
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
    
    var viewModel: ResultViewModel!
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpCollectionView()
        
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
        
        viewModel.results
            .map { (items) -> [SectionModel<Void, SearchResult>] in
                return [SectionModel(model: (), items: items)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        collectionView.rx.willDisplayCell
            .bind(to: viewModel.willDisplayCell)
            .disposed(by: bag)

        collectionView.rx.didScroll
            .filter { [unowned self] in
                let offsetY = self.collectionView.contentOffset.y
                let contentHeight = self.collectionView.contentSize.height
                return offsetY > contentHeight - self.collectionView.frame.size.height - 100
            }
            .bind(to: viewModel.didScrollToBottom)
            .disposed(by: bag)

        collectionView.rx.itemSelected
            .bind(to: viewModel.selectedItem)
            .disposed(by: bag)
    }

}

extension ResultViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
    }
    
    func setUpCollectionView() {
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalToSuperview()
        }
        
        registerLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? WaterfallLayout else { return }
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        layout.invalidateLayout()
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
}

extension ResultViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let result = viewModel.results.value[indexPath.item]
        switch result {
        case .collection:
            return 250
        case .photo(let photo):
            return photo.size(for: withWidth).height
        }
    }
}

//
//  CollectionViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CollectionViewController: UIViewController, Bindable, AppBarInjectable {
    internal var appBar: AppBar = .init()
    private let backButton = BarButton(systemName: "arrow.backward")
    lazy var orientationChange = PublishRelay<Orientation>()
    
    private let bag = DisposeBag()
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<Void, Photo>>(configureCell: {(datasource, collectionView, indexPath, photo) -> UICollectionViewCell in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        cell.placeholder(with: photo)
        return cell
    })
    
    var viewModel: CollectionViewModel!
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpCollectionView()
        
        addAppBar()
    }
    
    func bindViewModel() {
        dataSource.configureSupplementaryView = { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeader.identifier, for: indexPath) as! CollectionHeader
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
        
        viewModel.photos
            .map { (items) -> [SectionModel<Void, Photo>] in
                return [SectionModel(model: (), items: items)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        collectionView.rx.willDisplaySupplementaryView
            .bind(to: viewModel.willDisplaySupplementaryView)
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
        
        viewModel.collection
            .subscribe(onNext: { collection in
                print(collection)
            })
            .disposed(by: bag)
    }

}

extension CollectionViewController {
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
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeader.identifier)
        
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

extension CollectionViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        viewModel.photos.value[indexPath.item].size(for: withWidth).height
    }
    
    func collectionView(collectionView: UICollectionView, sizeForSectionHeaderViewForSection section: Int) -> CGSize {
        .init(width: view.bounds.width, height: 200)
    }
}

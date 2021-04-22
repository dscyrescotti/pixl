//
//  PhotosViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import RxSwift

class PhotosViewController: UIViewController, Bindable {
    
    var viewModel: PhotosViewModel!
    private var bag = DisposeBag()
    
    var photos: [UIImage] = .init()
    var testPhotos = [1,2,3,1,2,3,1,2,3].shuffled().compactMap {
        UIImage(named: String($0))
    }
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpCollectionView()
    }
    
    func bindViewModel() {
    }
}

extension PhotosViewController {
    func setUp() {
        view.backgroundColor = .systemPink
    }
    
    func setUpCollectionView() {
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        photos.append(contentsOf: testPhotos)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Warning")
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? WaterfallLayout else { return }
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        layout.invalidateLayout()
    }
}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else { fatalError() }
        cell.configure(with: photos[indexPath.item])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       let offsetY = scrollView.contentOffset.y
       let contentHeight = scrollView.contentSize.height

       if offsetY > contentHeight - scrollView.frame.size.height {
        self.photos.append(contentsOf: testPhotos)
          self.collectionView.reloadData()
       }
    }

}

extension PhotosViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        photos[indexPath.item].height(forWidth: withWidth)
    }
}

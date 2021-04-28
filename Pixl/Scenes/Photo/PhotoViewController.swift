//
//  PhotoViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 25/04/2021.
//

import UIKit
import SnapKit
import RxSwift
import Then
import RxCocoa

class PhotoViewController: UIViewController, Bindable {
    
    var viewModel: PhotoViewModel!
    
    private let bag = DisposeBag()
    
    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
    }
    
    private let headerView = AppBar()
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let contentView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    private let userProfileRow = UserProfileRow()
    private let descriptionRow = DescriptionRow()
    private let statisticsRow = StatisticsRow()
    private let exifRow = ExifRow()
    private let mapRow = MapRow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    func bindViewModel() {
        scrollView.rx.didScroll
            .subscribe { [unowned self] _ in
                let contentOffsetY = scrollView.contentOffset.y
                let maxY = view.safeAreaInsets.top
                let height = 250 - contentOffsetY
                let headerHeight = max(height, maxY)
                
                headerView.frame = .init(x: 0, y: contentOffsetY, width: view.frame.width, height: headerHeight)
                
                let point = maxY * 1.2
                if headerHeight <= point {
                    imageView.alpha = (headerHeight - maxY) / 20
                } else {
                    imageView.alpha = 1
                }
                
            }
            .disposed(by: bag)
        
        let photo = viewModel.photo.asObservable()
        
        let skipped = photo.skip(1)
            .subscribe(on: MainScheduler.instance)
        
        photo.map { ($0.urls.regular, $0.blurHash) }
            .subscribe(onNext: { [unowned self] in
                let placeholder = UIImage(blurHash: $0.1, size: CGSize(width: 20, height: 20))
                imageView.kf.setImage(with: URL(string: $0.0), placeholder: placeholder, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2)), .keepCurrentImageWhileLoading])
            })
            .disposed(by: bag)
        
        skipped
            .map { $0.user }
            .bind(to: userProfileRow.user)
            .disposed(by: bag)
        
        skipped
            .map { $0.photoDescription }
            .subscribe(onNext: { [unowned self] text in
                descriptionRow.configure(with: text ?? "No description", for: "Description")
            })
            .disposed(by: bag)
        
        skipped
            .map { photo -> [(String, String)] in
                return [("Likes", photo.likes.shorted()), ("Downloads", photo.downloads.shorted()), ("Views", photo.views.shorted())]
            }
            .bind(to: statisticsRow.observer)
            .disposed(by: bag)
        
        skipped
            .map { $0.exif }
            .subscribe(onNext: { [unowned self] exif in
                guard let exif = exif, exif.notNil else { return }
                exifRow.configure(with: exif, for: "Exif")
            })
            .disposed(by: bag)
        
        skipped
            .map { $0.location }
            .subscribe(onNext: { [unowned self] location in
                guard let location = location, let coordinate = location.coordinate else { return }
                mapRow.configure(with: coordinate, for: location.title)
            })
            .disposed(by: bag)
            
    }
    
}

extension PhotoViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(headerView)
        headerView.addSubview(imageView)
        contentView.addArrangedSubview(userProfileRow)
        contentView.addArrangedSubview(statisticsRow)
        contentView.addArrangedSubview(descriptionRow)
        contentView.addArrangedSubview(exifRow)
        contentView.addArrangedSubview(mapRow)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(toProfile))
    }
    
    @objc func toProfile() {
        viewModel.toProfile()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(255)
            make.bottom.equalTo(scrollView).offset(-10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(5)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(headerView)
        }
        
        statisticsRow.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(90)
        }
        
        exifRow.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
        }
        
        mapRow.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
        }
    }
}




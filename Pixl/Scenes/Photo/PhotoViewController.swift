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
    
    var color: UIColor
    
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
    private let tagRow = TagRow()
    
    init(color: UIColor) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        skipped
            .map { $0.tags }
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [unowned self] tags in
                tagRow.configure(with: tags.map { $0.title }, for: "Tags")
            })
            .disposed(by: bag)
        
        isLandscape
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] _ in
                updateBackButton()
            })
            .disposed(by: bag)
    }
    
    private let backButton = UIButton()
    lazy var isLandscape = PublishRelay<Bool>()
    
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
        contentView.addArrangedSubview(tagRow)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func toProfile() {
        viewModel.toProfile()
    }
    
    func updateBackButton() {
        backButton.frame = .init(origin: .zero, size: .init(width: view.orientation(portrait: 34, landscape: 25), height: view.orientation(portrait: 34, landscape: 25)))
        backButton.layer.cornerRadius = view.orientation(portrait: 17, landscape: 12.5)
        backButton.setImage(UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(pointSize: view.orientation(portrait: 20, landscape: 17))), for: .normal)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        isLandscape.accept(view.isLandscape)
        
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
        
        tagRow.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .label
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = color.revert
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.backgroundColor = color.similar.withAlphaComponent(0.6)
        backButton.layer.masksToBounds = true
        isLandscape.accept(view.isLandscape)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}

extension UIColor {
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
    
    var revert: UIColor {
        guard let flag = isLight() else { return .label }
        return flag ? .black : .white
    }
    
    var similar: UIColor {
        guard let flag = isLight() else { return .label }
        return flag ? .white : .black
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

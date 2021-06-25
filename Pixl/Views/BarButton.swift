//
//  BarButton.swift
//  Pixl
//
//  Created by Dscyre Scotti on 29/04/2021.
//

import UIKit
import RxCocoa
import RxSwift


class BarButton: UIButton {
    lazy var orientationChange = PublishRelay<Orientation>()
    private let bag = DisposeBag()
    private var orientation: Orientation? = nil
    
    private var color: UIColor = .label
    private var systemName: String {
        didSet {
            if let orientation = orientation {
                updateButton(orientation: orientation)
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            tintColor = isHighlighted ? color.withAlphaComponent(0.5) : color
        }
    }
    
    init(systemName: String) {
        self.systemName = systemName
        super.init(frame: .zero)
        bind()
    }
    
    func bind() {
        orientationChange
            .subscribe(onNext: { [unowned self] orientation in
                self.orientation = orientation
                updateButton(orientation: orientation)
            })
            .disposed(by: bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateButton(orientation: Orientation) {
        let frame: CGRect = .init(origin: .zero, size: .init(width: orientation.value(portrait: 34, landscape: 25), height: orientation.value(portrait: 36, landscape: 27)))
        self.frame = frame
        
        let radius: CGFloat = orientation.value(portrait: 18, landscape: 13.5)
        self.layer.cornerRadius = radius
        
        let configuration = UIImage.SymbolConfiguration(pointSize: orientation.value(portrait: 20, landscape: 17))
        self.setImage(UIImage(systemName: systemName, withConfiguration: configuration), for: .normal)
    }
    
    func configure(with color: UIColor) {
        self.color = color.revert
        tintColor = self.color
        backgroundColor = color.withAlphaComponent(0.7)
        layer.masksToBounds = true
        adjustsImageWhenHighlighted = false
    }
    
    func change(systemName: String) {
        self.systemName = systemName
    }
}

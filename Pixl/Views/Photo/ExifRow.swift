//
//  ExifRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 27/04/2021.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ExifRow: ReusableRow {
    
    private var gridView: UIStackView!
    private let boxes: [ExifBox] = [.init(), .init(), .init(), .init(), .init(), .init()]
    private var rows: [UIStackView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !subviews.isEmpty {
            gridView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.leading.trailing.equalTo(titleLabel).inset(-5)
                make.bottom.equalTo(self).offset(-10)
            }
            
            rows.forEach { row in
                row.snp.makeConstraints { make in
                    make.leading.trailing.equalTo(gridView)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with exif: Exif, for title: String) {
        isHidden = false
        titleLabel.text = title
        gridView = createGrid()
        let dict = [("Model", exif.model), ("Make", exif.make), ("Aperture", exif.aperture), ("Exposure Time", exif.exposureTime), ("Focal Length", exif.focalLength), ("ISO", exif.iso.string)]
        dict.enumerated().forEach { index, tup in
            boxes[index].configure(title: tup.0, value: tup.1 ?? "-")
        }
        if subviews.isEmpty {
            addSubview(titleLabel)
            addSubview(gridView)
        }
    }
    
    private func createGrid() -> UIStackView {
        let vstack = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fillEqually
        }
        let indices = (0, 1)
        for i in 0..<3 {
            let hstack = UIStackView().then {
                $0.axis = .horizontal
                $0.alignment = .center
                $0.distribution = .fillEqually
            }
            hstack.addArrangedSubview(boxes[indices.0 + 2 * i])
            hstack.addArrangedSubview(boxes[indices.1 + 2 * i])
            rows.append(hstack)
            vstack.addArrangedSubview(hstack)
        }
        return vstack
    }
}

class ExifBox: UIView {
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textAlignment = .center
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textAlignment = .center
    }
    
    private let vstack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fillEqually
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.label.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        vstack.addArrangedSubview(titleLabel)
        vstack.addArrangedSubview(subtitleLabel)
        
        addSubview(vstack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        vstack.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.top.bottom.equalTo(self).inset(5)
            make.leading.trailing.equalTo(self).inset(5)
        }
    }
    
    func configure(title: String, value: String) {
        subtitleLabel.text = title
        titleLabel.text = value
    }
}

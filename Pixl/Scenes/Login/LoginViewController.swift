//
//  LoginViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import Then
import SnapKit
import RxSwift
import Kingfisher

class LoginViewController: UIViewController, Bindable {
    
    var viewModel: LoginViewModel!
    private let bag = DisposeBag()
    
    let logoLabel = UILabel().then {
        $0.text = "pixl"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 50)
    }
    
    let loginButton = UIButton(type: .system).then {
        $0.setTitle("Log in", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .systemGreen
    }
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.kf.setImage(with: URL(string: "https://source.unsplash.com/random/300x599"))
    }
    
    let gradientView = GradientView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    func bindViewModel() {
        loginButton.rx.tap
            .bind(to: viewModel.loginTrigger)
            .disposed(by: bag)
        
        viewModel.isLoading
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] value in
                loginButton.isEnabled = !value
                loginButton.setTitle(value ? "Logging in..." : "Log in", for: value ? .disabled : .normal)
            })
            .disposed(by: bag)
        
        let timer = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .map { $0 % 10 }
        
        timer
            .subscribe(onNext: { [unowned self] value in
                imageView.kf.setImage(with: URL(string: "https://source.unsplash.com/random/300x60\(value)"), options: [ .keepCurrentImageWhileLoading])
            })
            .disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.kf.cancelDownloadTask()
    }

}

extension LoginViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        imageView.insertSubview(gradientView, at: 0)
        view.addSubview(loginButton)
        view.addSubview(logoLabel)
        
        view.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.width.equalTo(view.snp.width).multipliedBy(0.7)
        }
        
        logoLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
}

class GradientView: UIView {
    var topColor: UIColor = UIColor.clear

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
    }
}

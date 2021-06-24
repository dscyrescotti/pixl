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

class LoginViewController: UIViewController, Bindable {
    
    var viewModel: LoginViewModel!
    private let bag = DisposeBag()
    
    let loginButton = UIButton(type: .system).then {
        $0.setTitle("Log In", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .systemGreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    func bindViewModel() {
        loginButton.rx.tap
            .bind(to: viewModel.loginTrigger)
            .disposed(by: bag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] in
                loginButton.isEnabled = false
                loginButton.setTitle("Logging In...", for: .disabled)
            })
            .disposed(by: bag)
    }

}

extension LoginViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        title = "Login"
        
        view.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.snp.bottomMargin)
            make.width.equalTo(self.view.snp.width).multipliedBy(0.7)
        }
    }
}

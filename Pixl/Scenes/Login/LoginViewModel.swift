//
//  LoginViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Action
import RxSwift
import RxCocoa
import XCoordinator
import XCoordinatorRx
import AuthenticationServices

class LoginViewModel: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let bag = DisposeBag()
    
    lazy var loginTrigger = PublishRelay<Void>()
    lazy var isLoading = PublishRelay<Bool>()
    
    private let router: UnownedRouter<AuthRoute>
    
    init(_ router: UnownedRouter<AuthRoute>) {
        self.router = router
        super.init()
        self.bind()
    }
    
    func bind() {
        loginTrigger
            .subscribe(onNext: { [unowned self] in
                signIn()
            })
            .disposed(by: bag)
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        .init()
    }
    
    func signIn() {
        let authorize = Single<URL>.create { single in
            let disposable = Disposables.create()
            let authSession = ASWebAuthenticationSession(url: AuthService.shared.authorizeURL, callbackURLScheme: AuthService.shared.REDIRECT_URI.scheme) { url, error in
                if let error = error {
                    single(.failure(error))
                } else if let url = url {
                    single(.success(url))
                }
            }
            authSession.presentationContextProvider = self
            authSession.prefersEphemeralWebBrowserSession = true
            authSession.start()
            return disposable
        }
        
        authorize.subscribe(onSuccess: { [unowned self] url in
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let queryItems = components?.queryItems, let code = queryItems.filter({ $0.name == "code" }).first?.value {
                isLoading.accept(true)
                self.requestToken(code: code)
            }
            
        }, onFailure: { [unowned self] error in
            print(error.localizedDescription)
            isLoading.accept(false)
        })
        .disposed(by: bag)

    }
    
    func requestToken(code: String) {
        AuthService.shared.requestToken(code: code)
            .asSingle()
            .subscribe(onSuccess: { [unowned self] token in
                AuthService.shared.storeToken(token: token.accessToken)
                router.trigger(.home)
            }, onFailure: { [unowned self] error in
                print(error.localizedDescription)
                isLoading.accept(false)
            })
            .disposed(by: bag)
    }
}


//
//  AuthService.swift
//  Pixl
//
//  Created by Dscyre Scotti on 24/06/2021.
//

import Foundation
import KeychainAccess
import RxSwift
import RxAlamofire
import RxCocoa

class AuthService {
    
    static let shared = AuthService()
    
    private init() {
        guard let accessKey = ProcessInfo.processInfo.environment["ACCESS_KEY"] else { fatalError("[Error]: Missing access key")
        }
        guard let secretKey = ProcessInfo.processInfo.environment["SECRET_KEY"] else {
            fatalError("[Error]: Missing secret key")
        }
        guard let redirectUri = ProcessInfo.processInfo.environment["REDIRECT_URI"] else { fatalError("[Error]: Missing redirect uri") }
        self.ACCESS_KEY = accessKey
        self.SECRET_KEY = secretKey
        self.REDIRECT_URI = URL(string: redirectUri)!
        loadToken()
        print(accessToken)
    }
    
    var accessToken: String?
    private let keychain = Keychain(service: "com.dscyrescotti.pixl")
    
    private let ACCESS_KEY: String
    private let SECRET_KEY: String
    let REDIRECT_URI: URL
    private let DOMAIN: String = "unsplash.com"
    private let KEYCHAIN_KEY = "pixl.auth.token"
    private let API_SCHEDULER = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    var authorizeURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = DOMAIN
        components.path = "/oauth/authorize"
        components.queryItems = ["client_id": ACCESS_KEY, "redirect_uri": REDIRECT_URI.absoluteString, "response_type": "code", "scope": "public+read_user+write_user+read_photos+write_photos+write_likes+write_followers+read_collections+write_collections"].map { URLQueryItem(name: $0, value: $1) }
        return components.url!
    }
    
    func storeToken(token: String) {
        do {
            try keychain.set(token, key: KEYCHAIN_KEY)
            loadToken()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeToken() {
        try? keychain.remove(KEYCHAIN_KEY)
    }
    
    func loadToken() {
        accessToken = try? keychain.get(KEYCHAIN_KEY)
    }
    
    var hasToken: Bool {
        accessToken != nil
    }
    
    func requestToken(code: String) -> Observable<Token> {
        var components = URLComponents(string: "https://\(DOMAIN)/oauth/token")
        components?.queryItems = ["client_id": ACCESS_KEY, "redirect_uri": REDIRECT_URI.absoluteString, "client_secret": SECRET_KEY, "code": code, "grant_type": "authorization_code"].map { URLQueryItem(name: $0, value: $1) }
        guard let url = components?.url else {
            return Observable.empty()
        }
        var request = URLRequest(url: url)
        request.method = .post
        return RxAlamofire.request(request)
            .subscribe(on: API_SCHEDULER)
            .validate(statusCode: 200..<300)
            .data()
            .decode(type: Token.self, decoder: JSONDecoder())
            .asObservable()
    }
}

struct Token: Codable {
    var accessToken, tokenType, scope: String
    var createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

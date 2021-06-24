//
//  APIService.swift
//  Pixl
//
//  Created by Dscyre Scotti on 22/04/2021.
//

import Foundation
import RxAlamofire
import RxSwift

class APIService {
    static let shared = APIService()
    private init() {
        guard let accessKey = ProcessInfo.processInfo.environment["ACCESS_KEY"] else { fatalError("[Error]: Missing access key")
        }
        self.ACCESS_KEY = accessKey
    }
    
    private let ACCESS_KEY: String
    
    private let BASE_URL = "https://api.unsplash.com/"
    private let JSON_DECODER = JSONDecoder()
    private let API_SCHEDULER = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    private func urlRequest(endpoint: String, query: [String: Any], header: [String: String] = [:]) -> URLRequest? {
        guard var components = URLComponents(string: "\(BASE_URL)\(endpoint)") else { return nil }
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") } + [URLQueryItem(name: "client_id", value: ACCESS_KEY)]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        if let accessToken = AuthService.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        for dict in header {
            request.setValue(dict.value, forHTTPHeaderField: dict.key)
        }
        return request
    }
    
    private func alamofireRequest<T: Codable>(_ type: T.Type, request: URLRequest) -> Observable<T> {
        return RxAlamofire.request(request)
            .subscribe(on: API_SCHEDULER)
            .validate(statusCode: 200..<300)
            .data()
            .decode(type: type, decoder: JSON_DECODER)
            .asObservable()
    }
    
    func getPhotos(page: Int, perPage: Int = 50) -> Observable<[Photo]> {
        guard let request = urlRequest(endpoint: "photos", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest([Photo].self, request: request)
    }
    
    func getPhoto(id: String) -> Observable<Photo> {
        guard let request = urlRequest(endpoint: "photos/\(id)", query: [:]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        
        return alamofireRequest(Photo.self, request: request)
    }
    
    func getUserPhotos(username: String, type: String, page: Int, perPage: Int = 50) -> Observable<[Photo]> {
        guard let request = urlRequest(endpoint: "users/\(username)/\(type)", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest([Photo].self, request: request)
    }
    
    func getUserCollections(username: String, page: Int, perPage: Int = 50) -> Observable<[PhotoCollection]> {
        guard let request = urlRequest(endpoint: "users/\(username)/collections", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest([PhotoCollection].self, request: request)
    }
    
    func getUser(username: String) -> Observable<User> {
        guard let request = urlRequest(endpoint: "users/\(username)", query: [:]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest(User.self, request: request)
    }
    
    func getCollections(page: Int, perPage: Int = 50) -> Observable<[PhotoCollection]> {
        guard let request = urlRequest(endpoint: "collections", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest([PhotoCollection].self, request: request)
    }
    
    func getCollection(id: String) -> Observable<PhotoCollection> {
        guard let request = urlRequest(endpoint: "collections/\(id)", query: [:]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        
        return alamofireRequest(PhotoCollection.self, request: request)
    }
    
    func getCollectionPhotos(id: String, page: Int, perPage: Int = 50) -> Observable<[Photo]> {
        guard let request = urlRequest(endpoint: "collections/\(id)/photos", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest([Photo].self, request: request)
    }
    
    func getTopics() -> Observable<[Topic]> {
        guard let request = urlRequest(endpoint: "topics", query: ["per_page": 50]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest([Topic].self, request: request)
    }
    
    func searchPhotos(query: String, page: Int = 1, perPage: Int = 15) -> Observable<SearchPhoto> {
        guard let request = urlRequest(endpoint: "search/photos", query: ["query": query, "page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest(SearchPhoto.self, request: request)
    }
    
    func searchCollections(query: String, page: Int = 1, perPage: Int = 15) -> Observable<SearchCollection> {
        guard let request = urlRequest(endpoint: "search/collections", query: ["query": query, "page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest(SearchCollection.self, request: request)
    }
    
    func getMe() -> Observable<User> {
        guard let request = urlRequest(endpoint: "me", query: [:]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return alamofireRequest(User.self, request: request)
    }
    
}

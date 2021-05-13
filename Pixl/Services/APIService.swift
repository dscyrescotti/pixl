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
        guard let secretKey = ProcessInfo.processInfo.environment["SECRET_KEY"] else {
            fatalError("[Error]: Missing secret key")
        }
        self.ACCESS_KEY = accessKey
        self.SECRET_KEY = secretKey
    }
    
    private let ACCESS_KEY: String
    private let SECRET_KEY: String
    
    private let BASE_URL = "https://api.unsplash.com/"
    
    private let API_SCHEDULER = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    func urlRequest(endpoint: String, query: [String: Any], header: [String: String] = [:]) -> URLRequest? {
        guard var components = URLComponents(string: "\(BASE_URL)\(endpoint)") else { return nil }
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(ACCESS_KEY)", forHTTPHeaderField: "Authorization")
        for dict in header {
            request.setValue(dict.value, forHTTPHeaderField: dict.key)
        }
        return request
    }
    
    func getPhotos(page: Int, perPage: Int = 50) -> Observable<[Photo]> {
        guard let request = urlRequest(endpoint: "photos", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return RxAlamofire.request(request)
            .subscribe(on: API_SCHEDULER)
            .validate(statusCode: 200..<300)
            .data()
            .decode(type: [Photo].self, decoder: JSONDecoder())
            .asObservable()
    }
    
    func getPhoto(id: String) -> Observable<Photo> {
        guard let request = urlRequest(endpoint: "photos/\(id)", query: [:]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        
        return RxAlamofire.request(request)
            .subscribe(on: API_SCHEDULER)
            .validate(statusCode: 200..<300)
            .data()
            .decode(type: Photo.self, decoder: JSONDecoder())
            .asObservable()
    }
    
    func getUserPhotos(username: String, type: String, page: Int, perPage: Int = 50) -> Observable<[Photo]> {
        guard let request = urlRequest(endpoint: "/users/\(username)/\(type)", query: ["page": page, "per_page": perPage]) else {
            print("[Error]: Invalid url")
            return Observable.empty()
        }
        return RxAlamofire.request(request)
            .subscribe(on: API_SCHEDULER)
            .validate(statusCode: 200..<300)
            .data()
            .decode(type: [Photo].self, decoder: JSONDecoder())
            .asObservable()
    }
}

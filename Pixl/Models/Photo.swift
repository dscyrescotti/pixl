//
//  Photo.swift
//  Pixl
//
//  Created by Dscyre Scotti on 22/04/2021.
//

import Foundation
import AVFoundation
import CodableX
import MapKit

struct Photo: Codable, Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    var createdAt, updatedAt: String
    var width, height: Int
    var color: String
    @Defaultable var blurHash: String
    var likes: Int
    @Defaultable var views: Int
    @Defaultable var downloads: Int
    var likedByUser: Bool
    var photoDescription: String?
    var user: User
    var urls: Urls
    var links: PhotoLinks
    var exif: Exif?
    var location: Location?
    @Defaultable var tags: [Tag]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case photoDescription = "description"
        case user
        case views, downloads
//        case currentUserCollections = "current_user_collections"
        case urls, links, exif, location, tags
    }
    
    func size(for width: CGFloat) -> CGSize {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: CGSize(width: self.width, height: self.height),
            insideRect: boundingRect
        )
        return rect.size
    }
}

struct Exif: Codable {
    var make, model, exposureTime, aperture: String?
    var focalLength: String?
    var iso: Int?

    enum CodingKeys: String, CodingKey {
        case make, model
        case exposureTime = "exposure_time"
        case aperture
        case focalLength = "focal_length"
        case iso
    }
    
    var notNil: Bool {
        make != nil || exposureTime != nil || aperture != nil || focalLength != nil || iso != nil
    }
}

struct Location: Codable {
    var city, country: String?
    var position: Position
    
    var title: String {
        let name = [city, country].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        if name.isEmpty {
            return "Unknown place"
        }
        return name
    }
    
    var coordinate: CLLocation? {
        guard let latitude = position.latitude, let longitude = position.longitude else { return nil }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}

struct Position: Codable {
    var latitude, longitude: Double?
}

struct Tag: AnyCodable {
    var title: String
}

struct PhotoLinks: Codable {
    var linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

struct Urls: Codable {
    var raw, full, regular, small: String
    var thumb: String
}

struct User: AnyCodable {
    var id, username, name: String
    var portfolioURL: String?
    var bio, location: String?
    var totalLikes, totalPhotos, totalCollections: Int
    var instagramUsername, twitterUsername: String?
    var profileImage: ProfileImage
    var links: UserLinks
    var followersCount: Int?
    var followingCount: Int?
    @Defaultable var followedByUser: Bool

    enum CodingKeys: String, CodingKey {
        case id, username, name
        case portfolioURL = "portfolio_url"
        case bio, location
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
        case profileImage = "profile_image"
        case links
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case followedByUser = "followed_by_user"
    }
    
    var statsitics: [(String, String)] {
        [("Photos", totalPhotos.shorted()), ("Collections", totalCollections.shorted()), ("Likes", totalLikes.shorted())]
    }
}

struct UserLinks: Codable {
    var linksSelf, html, photos, likes: String
    var portfolio: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos, likes, portfolio
    }
}

struct ProfileImage: Codable {
    var small, medium, large: String
}

struct SearchPhoto: Codable {
    var total: Int
    var totalPages: Int
    var results: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case total, results
        case totalPages = "total_pages"
    }
    
    var searchModel: SearchModel {
        .init(title: "Photo", type: .photo, total: total, results: results.map { SearchResult.photo($0) })
    }
}

struct SearchModel {
    var title: String
    var type: SearchType
    var total: Int
    var results: [SearchResult]
}

enum SearchType {
    case photo, collection
}

struct LikePhoto: Codable {
    var photo: Photo
}

struct Empty: Codable { }

//
//  Photo.swift
//  Pixl
//
//  Created by Dscyre Scotti on 22/04/2021.
//

import Foundation
import AVFoundation

struct Photo: Codable, Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let createdAt, updatedAt: String
    let width, height: Int
    let color, blurHash: String
    let likes: Int
    let likedByUser: Bool
    let photoDescription: String?
    let user: User
//    let currentUserCollections: [CurrentUserCollection]
    let urls: Urls
    let links: PhotoLinks

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
//        case currentUserCollections = "current_user_collections"
        case urls, links
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

//struct CurrentUserCollection: Codable {
//    let id: Int
//    let title: String
//    let publishedAt, lastCollectedAt, updatedAt: Date
//    let coverPhoto, user: JSONNull?
//
//    enum CodingKeys: String, CodingKey {
//        case id, title
//        case publishedAt = "published_at"
//        case lastCollectedAt = "last_collected_at"
//        case updatedAt = "updated_at"
//        case coverPhoto = "cover_photo"
//        case user
//    }
//}

struct PhotoLinks: Codable {
    let linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}

struct User: Codable {
    let id, username, name: String
    let portfolioURL: String?
    let bio, location: String?
    let totalLikes, totalPhotos, totalCollections: Int
    let instagramUsername, twitterUsername: String?
    let profileImage: ProfileImage
    let links: UserLinks

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
    }
}

struct UserLinks: Codable {
    let linksSelf, html, photos, likes: String
    let portfolio: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos, likes, portfolio
    }
}

struct ProfileImage: Codable {
    let small, medium, large: String
}

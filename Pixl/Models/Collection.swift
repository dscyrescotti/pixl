//
//  Collection.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import Foundation
import CodableX

struct PhotoCollection: Codable {
    var id, title: String
    var description: String?
    var publishedAt, lastCollectedAt, updatedAt: String
    var curated, featured: Bool
    var totalPhotos: Int
    var collectionPrivate: Bool
    var shareKey: String
    @Defaultable var tags: [Tag]
    var links: CollectionLinks
    var user: User
    var coverPhoto: Photo?

    enum CodingKeys: String, CodingKey {
        case id, title
        case description
        case publishedAt = "published_at"
        case lastCollectedAt = "last_collected_at"
        case updatedAt = "updated_at"
        case curated, featured
        case totalPhotos = "total_photos"
        case collectionPrivate = "private"
        case shareKey = "share_key"
        case tags, links, user
        case coverPhoto = "cover_photo"
    }
}

struct CollectionLinks: Codable {
    let linksSelf, html, photos, related: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos, related
    }
}

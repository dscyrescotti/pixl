//
//  Topic.swift
//  Pixl
//
//  Created by Dscyre Scotti on 14/06/2021.
//

import Foundation
import CodableX

struct Topic: Codable {
    var id, slug, title, description: String
    var publishedAt, updatedAt, startsAt: String
    var featured: Bool
    var totalPhotos: Int
    var links: TopicLinks
    var status: String
    var owners: [User]
    @Defaultable var topContributors: [User]
    var coverPhoto: Photo

    enum CodingKeys: String, CodingKey {
        case id, slug, title
        case description
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
        case startsAt = "starts_at"
        case featured
        case totalPhotos = "total_photos"
        case links, status, owners
        case topContributors = "top_contributors"
        case coverPhoto = "cover_photo"
    }
}

struct TopicLinks: Codable {
    var linksSelf, html, photos: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos
    }
}

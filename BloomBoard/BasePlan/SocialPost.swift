//
//  SocialPost.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import Foundation
import SwiftData


@Model
class SocialPost: Identifiable {
    @Attribute(.unique) var id = UUID().description
    var title: String?
    var postDescription: String?
    var postType: PostType
    var platform: SocialMediaPlatform
    var postDay: Day
    
    init(id: String = UUID().description, title: String? = nil, postDescription: String? = nil, postType: PostType, platform: SocialMediaPlatform, postDay: Day) {
        self.id = id
        self.title = title
        self.postDescription = postDescription
        self.postType = postType
        self.platform = platform
        self.postDay = postDay
    }
}

enum PostType: String, CaseIterable,Codable {
    case LongFormVideo = "Long Form Video"
    case ShortFormVideo = "Short Form Video"
    case ImagePost = "Image Post"
    case QuizPost = "Quiz Post"
    case TextPost = "Text Post"
    case CrossPost = "Cross Post"
}

enum SocialMediaPlatform: String, CaseIterable,Codable {
    case Reddit
    case Youtube
    case X
    
    var availablePostTypes: [PostType] {
        switch self {
        case .Reddit:
            return [.ImagePost, .TextPost, .CrossPost]
        case .Youtube:
            return [.ImagePost, .LongFormVideo, .ShortFormVideo, .QuizPost]
        case .X:
            return [.ImagePost, .TextPost]
        }
    }
}

enum Day: String, CaseIterable,Codable {
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

//
//  SocialPost.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import Foundation

struct SocialPost: Decodable, Identifiable {
    var id = UUID().description
    var title: String?
    var description: String?
    var postType: PostType
    var platform: SocialMediaPlatform
    var postDay: Day
    
    static var skeletonWeekExample: [SocialPost] {
        [
            SocialPost(postType: PostType.LongFormVideo, platform: SocialMediaPlatform.Youtube, postDay: Day.Sunday),
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.X, postDay: Day.Sunday),
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.Reddit, postDay: Day.Sunday),
            
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.Reddit, postDay: Day.Monday),
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.X, postDay: Day.Monday),
            SocialPost(postType: PostType.ShortFormVideo, platform: SocialMediaPlatform.Youtube, postDay: Day.Monday),
            
            SocialPost(postType: PostType.ShortFormVideo, platform: SocialMediaPlatform.Youtube, postDay: Day.Tuesday),
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.X, postDay: Day.Tuesday),
            
            
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.Reddit, postDay: Day.Wednesday),
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.X, postDay: Day.Wednesday),
            SocialPost(postType: PostType.ShortFormVideo, platform: SocialMediaPlatform.Youtube, postDay: Day.Wednesday),
            
            
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.X, postDay: Day.Thursday),
            SocialPost(postType: PostType.QuizPost, platform: SocialMediaPlatform.Youtube, postDay: Day.Thursday),
            
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.X, postDay: Day.Friday),
            SocialPost(postType: PostType.ImagePost, platform: SocialMediaPlatform.Reddit, postDay: Day.Friday),
            
        ]
    }
}

enum PostType: String, Decodable,CaseIterable {
    case LongFormVideo = "Long Form Video"
    case ShortFormVideo = "Short Form Video"
    case ImagePost = "Image Post"
    case QuizPost = "Quiz Post"
    case TextPost = "Text Post"
}

enum SocialMediaPlatform: String, Decodable, CaseIterable {
    case Reddit
    case Youtube
    case X
}

enum Day: String, Decodable, CaseIterable {
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

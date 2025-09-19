//
//  Post.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/2/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Post: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    @Attribute(.externalStorage) var image: Data?
    var postDate: Date?
    var creationDate: Date
    var performance: Performance?
    var socialMedias: [SocialMedias]?
    
    init(id: UUID = UUID(), title: String, image: Data? = nil, postDate: Date? = nil, performance: Performance? = nil, socialMedias: [SocialMedias]? = nil) {
        self.id = id
        self.title = title
        self.image = image
        self.postDate = postDate
        self.creationDate = Date()
        self.performance = performance
        self.socialMedias = socialMedias
    }
    
    
    static var testPost = Post(title: "How is my SwiftData Model?", image: UIImage(named: "sampleImage")?.pngData())
}


enum Performance: String, CaseIterable, Codable {
    case unrated = "Unrated"
    case decent = "Decent"
    case good = "Good"
    case excellent = "Excellent"
    
    var color: Color {
        switch self {
        case .unrated:
            return .gray
        case .decent:
            return .brown
        case .good:
            return .teal
        case .excellent:
            return .yellow
        }
    }
}

enum SocialMedias: String, CaseIterable, Codable {
    case facebook = "Facebook"
    case instagram = "Instagram"
    case reddit = "Reddit"
    case threads = "Threads"
    case tiktok = "TikTok"
    case x = "X"
    case youtube = "Youtube"
}

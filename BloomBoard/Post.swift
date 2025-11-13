//
//  Post.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/2/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: Post Model
@Model
class Post: Identifiable {
    @Attribute(.unique) private(set) var id: UUID
    var title: String
    @Attribute(.externalStorage) var image: Data?
    var postDate: Date?
    private(set) var creationDate: Date
    var performance: Performance?
    var socialMedias: [SocialMedia]?
    var originalPlatform: SocialMedia?
    
    init(title: String, image: Data? = nil, postDate: Date? = nil, performance: Performance? = nil, socialMedias: [SocialMedia]? = nil, originalPlatform: SocialMedia? = nil) {
        self.id = UUID()
        self.title = title
        self.image = image
        self.postDate = postDate
        self.creationDate = Date()
        self.performance = performance
        self.socialMedias = socialMedias
        self.originalPlatform = originalPlatform
    }
    
    
    static var testPost = Post(title: "How is my SwiftData Model?", image: UIImage(named: "sampleImage")?.pngData())
}


// MARK: Performance Enum
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
            return .yellow
        case .excellent:
            return .green
        }
    }
}

// MARK: Social Media Enum
enum SocialMedia: String, CaseIterable, Codable, Identifiable {
    var id: Self { self }
    
    case none = "None"
    case facebook = "Facebook"
    case instagram = "Instagram"
    case reddit = "Reddit"
    case threads = "Threads"
    case tiktok = "TikTok"
    case x = "X"
    case youtube = "YouTube"
    
    var shortName: String {
        switch self {
        case .none: return ""
        case .facebook: return "FB"
        case .instagram: return "IG"
        case .reddit: return "RD"
        case .threads: return "TH"
        case .tiktok: return "TT"
        case .x: return "X"
        case .youtube: return "YT"
        }
    }
    
}

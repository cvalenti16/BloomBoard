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
    private(set) var id: UUID = UUID()
    var title: String = ""
    @Attribute(.externalStorage) var image: Data?
    private(set) var creationDate: Date = Date()
    var isAITrainingPost: Bool = false
    
    init(title: String, image: Data? = nil, isAITrainingPost: Bool = false) {
        self.title = title
        self.image = image
        self.isAITrainingPost = isAITrainingPost
    }
    
    static let testPosts = [
        Post(title: "Is MVVM needed in SwiftUI?", image: UIImage(named: "sampleImage")?.jpegData(compressionQuality: 0.90))
    ]
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
    case linkedIn = "LinkedIn"
}

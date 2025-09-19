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
    
    init(id: UUID = UUID(), title: String, image: Data? = nil, postDate: Date? = nil, performance: Performance? = nil) {
        self.id = id
        self.title = title
        self.image = image
        self.postDate = postDate
        self.creationDate = Date()
        self.performance = performance
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
            return .clear
        case .decent:
            return .brown
        case .good:
            return .gray
        case .excellent:
            return .yellow
        }
    }
}

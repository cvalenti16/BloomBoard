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
class Post:Identifiable {
    @Attribute(.unique) var id = UUID().description
    var title: String
    @Attribute(.externalStorage) var image: Data?
    var postDate: Date?
    var creationDate: Date
    var performance: Performance?
    
    init(id: String = UUID().description, title: String, image: Data? = nil, completedDate: Date? = nil, performance: Performance? = nil) {
        self.id = id
        self.title = title
        self.image = image
        self.postDate = completedDate
        self.creationDate = Date()
        self.performance = performance
    }
    
    enum Performance: String, CaseIterable,Codable {
        case unrated = "Unrated"
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        
        var color: Color {
            switch self {
            case .unrated:
                return .clear
            case .bronze:
                return .brown
            case .silver:
                return .gray
            case .gold:
                return .yellow
            }
        }
    }
    
    static var testPost = Post(title: "How is my SwiftData Model?", image: UIImage(named: "sampleImage")?.pngData())

}



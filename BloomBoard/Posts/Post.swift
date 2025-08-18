//
//  Post.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/2/25.
//

import Foundation
import SwiftData

@Model
class Post:Identifiable {
    @Attribute(.unique) var id = UUID().description
    var title: String
    var image:String?
    var postDate: Date?
    var creationDate: Date
    var performance: Performance?
    
    init(id: String = UUID().description, title: String, image: String? = nil, completedDate: Date? = nil, performance: Performance? = nil) {
        self.id = id
        self.title = title
        self.image = image
        self.postDate = completedDate
        self.creationDate = Date()
        self.performance = performance
    }
    
    enum Performance: String, CaseIterable,Codable {
        case unrated = "Unrated"
        case poor = "Poor"
        case good = "Good"
        case excellent = "Excellent"
    }
    
    static var testPost = Post(title: "How is my SwiftData Model?", image: "PostSampleImage")

}



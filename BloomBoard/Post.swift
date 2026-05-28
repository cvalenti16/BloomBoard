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

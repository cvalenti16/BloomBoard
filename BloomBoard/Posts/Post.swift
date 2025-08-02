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
    var image:String
    var date: Date
    
    
    init(id: String = UUID().description, title: String, image: String, date: Date) {
        self.id = id
        self.title = title
        self.image = image
        self.date = date
    }

}

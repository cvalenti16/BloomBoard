//
//  EditPostSheet.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct FormEditPost: View {
    @Bindable var post: Post
    
    @State private var imageProperties = ImageProperties()
    @State private var draftTitle: String
    
    init(post: Post) {
        self.post = post
        _draftTitle = State(initialValue: post.title)
        
        if let data = post.image {
            imageProperties.uiImage = UIImage(data: data)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                StartingView(title: $draftTitle)
            }
            .navigationTitle(UIStrings.editPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                    PostSheetToolbar(postTitle: draftTitle, post: post, isEditing: true)
            }
        }
        .environment(imageProperties)
    }
}

#Preview {
    FormEditPost(post: .testPost)
        .preferredColorScheme(.dark)
}

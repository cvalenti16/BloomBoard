//
//  EditPostSheet.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PostEditorView: View {
    @State private var imageProperties = ImageProperties()
    @State private var title: String
    @State private var post: Post?
   
    init(post: Post? = nil) {
        _title = State(initialValue: post?.title ?? "")
        self.post = post
        
        if let data = post?.image {
            imageProperties.uiImage = UIImage(data: data)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                PostFieldsView(title: $title)
            }
            .navigationTitle(UIStrings.editPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                    PostSheetToolbar(postTitle: title, post: post)
            }
        }
        .environment(imageProperties)
    }
}

#Preview {
    PostEditorView(post: .testPost)
        .preferredColorScheme(.dark)
}

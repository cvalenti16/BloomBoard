//
//  AddPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/4/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct FormAddPost: View {
    @State private var postTitle = ""
    @State private var imageProperties = ImageProperties()
    
    var body: some View {
        NavigationStack {
            VStack {
                
            PostFieldsView(title: $postTitle)
                
            }
            .navigationTitle(UIStrings.createPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                PostSheetToolbar(postTitle: postTitle, isEditing: false)
            }
        }
        .environment(imageProperties)
    }
}


#Preview {
    FormAddPost()
        .preferredColorScheme(.dark)
}

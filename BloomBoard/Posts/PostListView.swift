//
//  PostListView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/6/25.
//

import SwiftUI
import SwiftData

struct PostListView: View {
    @Query var posts: [Post]
    @State private var showAddSheet = false
    
    
    var body: some View {
        NavigationStack {
            if (posts.isEmpty) {
                Button {
                    showAddSheet.toggle()
                } label: {
                    Text(PostStrings.createPost)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.thinMaterial)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                }
            } else {
                List(posts) { post in
                    PostItemView(post: post)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPostView()
        }
        
    }
}

#Preview {
    PostListView()
}

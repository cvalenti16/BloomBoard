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
    @State private var postDetailPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $postDetailPath) {
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
                    PostItemView(post: post) { post in
                        postDetailPath.append(post)
                    }
                }
                .navigationDestination(for: Post.self) { post in
                    PostDetailView(post: post)
                }
                
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddSheet.toggle()
                        } label: {
                            Image(systemName: UIIcons.addIcon)
                                .foregroundStyle(.white)
                        }
                    }
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

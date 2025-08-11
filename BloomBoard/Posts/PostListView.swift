//
//  PostListView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/6/25.
//

import SwiftUI
import SwiftData

struct PostListView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: [
        SortDescriptor(\Post.title , order: .forward),
        SortDescriptor(\Post.creationDate, order: .reverse)
       
    ]) var sortedPosts: [Post]
    
  
    
    @State private var showAddSheet = false
    @State private var postDetailPath = NavigationPath()
    @State private var showDeleteAlert = false
    @State private var postToDelete: Post?
    
    
    var body: some View {
        NavigationStack(path: $postDetailPath) {
            if (sortedPosts.isEmpty) {
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
                List(sortedPosts) { post in
                    PostItemView(post: post) { post in
                        postDetailPath.append(post)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            postToDelete = post
                            showDeleteAlert.toggle()
                        } label: {
                            Image(systemName: UIIcons.trashIcon)
                                .tint(.red)
                        }
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
                
                .alert(PostStrings.deletePost, isPresented: $showDeleteAlert) {
                    Button(UIStrings.deleteString, role: .destructive) {
                        if let post = postToDelete {
                            modelContext.delete(post)
                        }
                    }
                    Button(UIStrings.cancelString, role: .cancel) {
                        postToDelete = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPostView()
                .presentationDetents([.fraction(0.60)])
        }
    }
}

#Preview {
    PostListView()
}

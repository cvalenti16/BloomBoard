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
    
    @State private var showAddSheet = false
    @State private var postDetailPath = NavigationPath()
    @State private var showDeleteAlert = false
    @State private var postToDelete: Post?
    @State private var postToEdit: Post?
    
    let posts: [Post]
    let isDrafts: Bool
    
    var body: some View {
        NavigationStack(path: $postDetailPath) {
            if (posts.isEmpty) {
                EmptyListView(isDrafts: isDrafts, showAddSheet: $showAddSheet)
                    .navigationTitle(isDrafts ? PostStrings.draftPosts: PostStrings.publishedPosts)
                    .toolbar {
                        if (isDrafts) {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showAddSheet.toggle()
                                } label: {
                                    Image(systemName: UIIcons.addIcon)
                                }
                            }
                            
                        }
                    }
                
            } else {
                PopulatedListView(posts: posts, postDetailPath: $postDetailPath, postToDelete: $postToDelete, postToEdit: $postToEdit, showDeleteAlert: $showDeleteAlert)
                    .navigationDestination(for: Post.self) { post in
                        PostDetailView(post: post)
                    }
                    .navigationTitle(isDrafts ? PostStrings.draftPosts : PostStrings.publishedPosts)
                    .toolbar {
                        if (isDrafts) {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showAddSheet.toggle()
                                } label: {
                                    Image(systemName: UIIcons.addIcon)
                                }
                            }
                            
                        }
                    }
                    .alert(PostStrings.deletePost, isPresented: $showDeleteAlert) {
                        Button(UIStrings.deleteString, role: .destructive) {
                            if let post = postToDelete {
                                modelContext.delete(post)
                                postToDelete = nil
                            }
                        }
                        Button(UIStrings.cancelString, role: .cancel) {
                            postToDelete = nil
                        }
                    }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPostSheet()
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(item: $postToEdit) { post in
            AddPostSheet(postToEdit: post)
                .presentationDetents([.fraction(0.60)])
        }
        .tint(.text)
        
    }
}

private struct EmptyListView: View {
    let isDrafts: Bool
    @Binding var showAddSheet: Bool
    
    var body: some View {
        VStack {
            Text(isDrafts ? PostStrings.noDrafts : PostStrings.noPublishedPosts)
                .font(.title3)
                .bold()
            
            if(isDrafts) {
                Button {
                    showAddSheet.toggle()
                } label: {
                    Text(PostStrings.createPost)
                        .defaultButtonStyle()
                }
            }
        }
    }
}


private struct PopulatedListView: View {
    let posts: [Post]
    @Binding var postDetailPath: NavigationPath
    @Binding var postToDelete: Post?
    @Binding var postToEdit: Post?
    @Binding var showDeleteAlert: Bool
    
    var body: some View {
        List(posts) { post in
            
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
            .swipeActions(edge: .trailing) {
                Button {
                    postToEdit = post
                } label: {
                    Image(systemName: UIIcons.edit)
                        .tint(.yellow)
                }
            }
        }
        .animation(.default, value: posts)

        
    }
}

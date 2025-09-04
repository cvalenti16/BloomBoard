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
    
    @State private var state = PostListState()

    
    let posts: [Post]
    let isDrafts: Bool
    
    var body: some View {
        NavigationStack(path: $state.postDetailPath) {
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
                PopulatedListView(posts: posts)
                    .environment(state)
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
                    .alert(PostStrings.deletePost, isPresented: $state.showDeleteAlert) {
                        Button(UIStrings.deleteString, role: .destructive) {
                            if let post = state.postToDelete {
                                modelContext.delete(post)
                                state.postToDelete = nil
                            }
                        }
                        Button(UIStrings.cancelString, role: .cancel) {
                            state.postToDelete = nil
                        }
                    }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPostSheet()
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(item: $state.postToEdit) { post in
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
    
    @Environment(PostListState.self) var state
    
    var body: some View {
        List(posts) { post in
            
            PostItemView(post: post) { post in
                state.postDetailPath.append(post)
            }
            .swipeActions(edge: .trailing) {
                Button {
                    state.postToDelete = post
                    state.showDeleteAlert.toggle()
                } label: {
                    Image(systemName: UIIcons.trashIcon)
                        .tint(.red)
                }
            }
            .swipeActions(edge: .trailing) {
                Button {
                    state.postToEdit = post
                } label: {
                    Image(systemName: UIIcons.edit)
                        .tint(.yellow)
                }
            }
        }
        .animation(.default, value: posts)

        
    }
}

@Observable
private class PostListState {
    var postDetailPath = NavigationPath()
    var postToDelete: Post?
    var postToEdit: Post?
    var showDeleteAlert = false
}


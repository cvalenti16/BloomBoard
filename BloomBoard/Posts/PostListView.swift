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
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    
    @State private var showAddSheet = false
    @State private var postListProperties = PostListProperties()
    
    let posts: [Post]
    let isDrafts: Bool
    
    var body: some View {
        NavigationStack(path: $postListProperties.postDetailPath) {
            Group {
                if (posts.isEmpty) {
                    EmptyListView(isDrafts: isDrafts, showAddSheet: $showAddSheet)
                } else {
                    PopulatedListView(posts: posts)
                        .environment(postListProperties)
                        .navigationDestination(for: Post.self) { post in
                            PostDetailView(post: post)
                        }
                        .alert(UIStrings.deletePost, isPresented: $postListProperties.showDeleteAlert) {
                            Button(UIStrings.deleteString, role: .destructive) {
                                if let post = postListProperties.postToDelete {
                                    modelContext.delete(post)
                                    postListProperties.postToDelete = nil
                                }
                            }
                            Button(UIStrings.cancelString, role: .cancel) {
                                postListProperties.postToDelete = nil
                            }
                        }
                }
            }
            .navigationTitle(isDrafts ? UIStrings.draftPosts: UIStrings.publishedPosts)
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
                
                //Theme toggle
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        switch selectedAppearance {
                        case .dark: selectedAppearance = .light
                        case .light: selectedAppearance = .dark
                        }
                    } label: {
                        Image(systemName: selectedAppearance == .dark ? UIIcons.moon : UIIcons.sun)
                            .symbolEffect(.bounce, value: selectedAppearance)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            FormAddPost()
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
            Text(isDrafts ? UIStrings.noDrafts : UIStrings.noPublishedPosts)
                .font(.title3)
                .bold()
            
            if(isDrafts) {
                Button {
                    showAddSheet.toggle()
                } label: {
                    Text(UIStrings.createPost)
                        .defaultButtonStyle()
                }
            }
        }
    }
}

private struct PopulatedListView: View {
    let posts: [Post]
    
    @Environment(PostListProperties.self) var state
    
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
        }
    }
}


@Observable
private class PostListProperties {
    var postDetailPath = NavigationPath()
    var postToDelete: Post?
    var postToEdit: Post?
    var showDeleteAlert = false
}


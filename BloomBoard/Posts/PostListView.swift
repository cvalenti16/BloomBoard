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
    @State private var postListProperties = PostListProperties()
    
    let posts: [Post]
    let isDrafts: Bool
    
    var body: some View {
        NavigationStack(path: $postListProperties.postDetailPath) {
            Group {
                if (posts.isEmpty) {
                    EmptyListView(isDrafts: isDrafts)
                } else {
                    PopulatedListView(posts: posts)
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
                Group {
                    PostListToolbar(isDrafts: isDrafts)
                }
            }
        }
        .sheet(isPresented: $postListProperties.showAddSheet) {
            FormAddPost()
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postListProperties.showSocialMediaPicker, content: {
            SocialMediaDefaultPicker()
        })
        .tint(.text)
        .environment(postListProperties)

    }
}
private struct EmptyListView: View {
    let isDrafts: Bool
    @Environment(PostListProperties.self) var postListProperties

    var body: some View {
        VStack {
            Text(isDrafts ? UIStrings.noDrafts : UIStrings.noPublishedPosts)
                .font(.title3)
                .bold()
            
            if(isDrafts) {
                Button {
                    postListProperties.showAddSheet.toggle()
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

    @Environment(PostListProperties.self) var postListProperties
    
    var body: some View {
        List(posts) { post in
            
            PostItemView(post: post) { post in
                postListProperties.postDetailPath.append(post)
            }
            .swipeActions(edge: .trailing) {
                Button {
                    postListProperties.postToDelete = post
                    postListProperties.showDeleteAlert.toggle()
                } label: {
                    Image(systemName: UIIcons.trashIcon)
                        .tint(.red)
                }
            }
        }
    }
}

// MARK: Toolbar
private struct PostListToolbar: ToolbarContent {
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    
    @Environment(PostListProperties.self) var postListProperties
    
    let isDrafts: Bool

    var body: some ToolbarContent {
        if isDrafts {
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
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    postListProperties.showAddSheet.toggle()
                } label: {
                    Image(systemName: UIIcons.addIcon)
                }
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    postListProperties.showSocialMediaPicker.toggle()
                } label: {
                    Image(systemName: UIIcons.socialMedia)
                }
            }
        }
    }
}



// MARK: Social Media Default Picker
private struct SocialMediaDefaultPicker: View {
    @AppStorage("defaultSocialMedia") private var defaultSocialMedia: SocialMedias = .none
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                List(SocialMedias.allCases) { platform in
                    Button {
                        defaultSocialMedia = platform
                    } label: {
                        HStack {
                            Text(platform.rawValue)
                            Spacer()
                            if platform == defaultSocialMedia {
                                Image(systemName: UIIcons.checkmark)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
                .scrollDisabled(true)
                
                Button {
                    dismiss()
                } label: {
                    Text(UIStrings.close)
                        .defaultButtonStyle()
                }
            }
            .navigationTitle(UIStrings.selectDefaultPlatform)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}





@Observable
private class PostListProperties {
    var postDetailPath = NavigationPath()
    var postToDelete: Post?
    var postToEdit: Post?
    var showAddSheet = false
    var showDeleteAlert = false
    var showSocialMediaPicker = false
}


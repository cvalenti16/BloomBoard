//
//  PostListView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/6/25.
//

import SwiftUI
import SwiftData

//MARK: PostListView
struct PostListView: View {
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
                        }.postDeleteAlert(
                            showDeleteAlert: $postListProperties.showDeleteAlert
                        )
                }
            }
            .navigationTitle(isDrafts ? UIStrings.draftPosts: UIStrings.publishedPosts)
            .toolbar {
                PostListToolbar(selectMissingPlatfrom: $postListProperties.selectedMissingPlatform, isDrafts: isDrafts)
            }
        }
        .sheet(isPresented: $postListProperties.showAddSheet) {
            FormAddPost()
        }
        .sheet(isPresented: $postListProperties.showSocialMediaPicker, content: {
            SocialMediaDefaultPicker()
        })
        .tint(.text)
        .environment(postListProperties)
        
    }
}

// MARK: PostListProperties
@Observable
private class PostListProperties {
    var postDetailPath = NavigationPath()
    var postToDelete: Post?
    var showAddSheet = false
    var showDeleteAlert = false
    var showSocialMediaPicker = false
    var selectedMissingPlatform: SocialMedia? = nil
}

// MARK: EmptyListView
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

// MARK: PopulatedListView
private struct PopulatedListView: View {
    let posts: [Post]
    
    @Environment(PostListProperties.self) var postListProperties
    
    var filteredPosts: [Post] {
        if let platform = postListProperties.selectedMissingPlatform {
            return posts.filter { !($0.socialMedias?.contains(platform) ?? false)}
        } else {
            return posts
        }
    }
    
    var body: some View {
        List(filteredPosts) { post in
            
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

// MARK: PostDeleteAlert
private struct PostDeleteAlert: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Environment(PostListProperties.self) private var postListProperties
    @Binding var showDeleteAlert: Bool
    
    
    func body(content: Content) -> some View {
        content.alert(UIStrings.deletePost, isPresented: $showDeleteAlert) {
            Button(UIStrings.delete, role: .destructive) {
                if let post = postListProperties.postToDelete {
                    modelContext.delete(post)
                    postListProperties.postToDelete = nil
                }
            }
            Button(UIStrings.cancel, role: .cancel) {
                postListProperties.postToDelete = nil
            }
        }
    }
}

private extension View {
    func postDeleteAlert(showDeleteAlert: Binding<Bool>) -> some View {
        self.modifier(PostDeleteAlert(showDeleteAlert: showDeleteAlert))
    }
}

// MARK: PostListToolbar
private struct PostListToolbar: ToolbarContent {
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    
    @Environment(PostListProperties.self) var postListProperties
    @Binding var selectMissingPlatfrom: SocialMedia?
    
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
            
            ToolbarItem {
                Button(UIStrings.add, systemImage: UIIcons.addIcon) {
                    postListProperties.showAddSheet.toggle()
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed)
            }
            
            ToolbarItem {
                Button(UIStrings.socialMediaPicker, systemImage: UIIcons.socialMedia) {
                    postListProperties.showSocialMediaPicker.toggle()
                }
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Text(UIStrings.notPostedOn)
                    
                    Picker(UIStrings.notPostedOn, selection: $selectMissingPlatfrom) {
                        ForEach(SocialMedia.allCases.filter{ $0 != .none}) { platform in
                            Text(platform.rawValue).tag(platform as SocialMedia?)
                        }
                    }
                    
                    if self.selectMissingPlatfrom != nil {
                        Button(UIStrings.clear) {
                            selectMissingPlatfrom = nil
                        }
                    }
                } label: {
                    Label(UIStrings.filter, systemImage: UIIcons.filter)
                }
            }
        }
    }
}

// MARK: SocialMediaDefaultPicker
private struct SocialMediaDefaultPicker: View {
    @AppStorage("defaultSocialMedia") private var defaultSocialMedia: SocialMedia = .none
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                List(SocialMedia.allCases) { platform in
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

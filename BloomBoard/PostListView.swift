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
    @State private var postListState = PostListState()
    @State private var searchTerm = ""
    
    @AppStorage("didFinishOnboarding") private var didFinishOnboarding = false
    
    let posts: [Post]
    let isDrafts: Bool
    
    var searchedPosts: [Post] {
        if searchTerm.isEmpty {
            return posts
        } else {
            return posts.filter { posts in
                posts.title.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
    
    var filteredPosts: [Post] {
        if let platform = postListState.selectedMissingPlatform {
            return searchedPosts.filter { !($0.socialMedias?.contains(platform) ?? false)}
        } else {
            return searchedPosts
        }
    }
    
    var currentNavigationTitle: String {
        let count = filteredPosts.count
        
        if isDrafts {
            return String(
                format: UIStrings.navigationTitle,
                UIStrings.draftPosts,
                count
            )
        } else if let platform = postListState.selectedMissingPlatform {
            return String(
                format: UIStrings.navigationTitle,
                platform.rawValue,
                count
            )
            
        } else {
            return String(
                format: UIStrings.navigationTitle,
                UIStrings.allPublished,
                count
            )
        }
    }
    
    var body: some View {
        NavigationStack(path: $postListState.postDetailPath) {
            PopulatedListView(posts: filteredPosts)
                .navigationDestination(for: Post.self) { post in
                    PostDetailView(post: post)
                }
                .postDeleteAlert()
                .navigationTitle(currentNavigationTitle)
                .toolbar {
                    PostListToolbar(isDrafts: isDrafts)
                }
        }
        .tint(.text)
        .environment(postListState)
        .searchable(text: $searchTerm)
        .sheet(isPresented: $postListState.showAddSheet) {
            PostEditorView()
                .presentationDetents([.fraction(0.60)])
        }
        .overlay {
            PostListOverlay(
                searchedPosts: searchedPosts,
                filteredPosts: filteredPosts,
                searchTerm: searchTerm,
                isDrafts: isDrafts
            )
        }
    }
}

// MARK: PostListProperties
@Observable
private class PostListState {
    var postDetailPath = NavigationPath()
    var postToDelete: Post?
    var showAddSheet = false
    var showDeleteAlert = false
    var selectedMissingPlatform: SocialMedia? = nil
}

// MARK: PopulatedListView
private struct PopulatedListView: View {
    let posts: [Post]
    
    @Environment(PostListState.self) var postListState
    
    var body: some View {
        List(posts) { post in
            PostItemView(post: post) { post in
                postListState.postDetailPath.append(post)
            }
            .swipeActions(edge: .trailing) {
                Button {
                    postListState.postToDelete = post
                    postListState.showDeleteAlert.toggle()
                } label: {
                    Image(systemName: UIIcons.trash)
                        .tint(.red)
                }
            }
        }
    }
}

// MARK: PostDeleteAlert
private struct PostDeleteAlert: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Environment(PostListState.self) private var postListState
    
    
    func body(content: Content) -> some View {
        @Bindable var postListState = postListState

        content.alert(UIStrings.deletePost, isPresented: $postListState.showDeleteAlert) {
            Button(UIStrings.delete, role: .destructive) {
                if let post = postListState.postToDelete {
                    modelContext.delete(post)
                    postListState.postToDelete = nil
                }
            }
            Button(UIStrings.cancel, role: .cancel) {
                postListState.postToDelete = nil
            }
        }
    }
}

private extension View {
    func postDeleteAlert() -> some View {
        self.modifier(PostDeleteAlert())
    }
}

// MARK: PostListToolbar
private struct PostListToolbar: ToolbarContent {
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    
    @Environment(PostListState.self) var postListState
    
    let isDrafts: Bool
    
    var body: some ToolbarContent {
        @Bindable var postListState = postListState
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
        
        if isDrafts {
            ToolbarItem {
                Button(UIStrings.add, systemImage: UIIcons.add) {
                    postListState.showAddSheet.toggle()
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed)
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Text(UIStrings.notPostedOn)
                    
                    Picker(UIStrings.notPostedOn, selection: $postListState.selectedMissingPlatform) {
                        ForEach(SocialMedia.allCases.filter{ $0 != .none}) { platform in
                            Text(platform.rawValue).tag(platform as SocialMedia?)
                        }
                    }
                    
                    if postListState.selectedMissingPlatform != nil {
                        Button(UIStrings.clear) {
                            postListState.selectedMissingPlatform = nil
                        }
                    }
                } label: {
                    Label(UIStrings.filter, systemImage: UIIcons.filter)
                }
            }
        }
    }
}

private struct PostListOverlay: View {
    let searchedPosts: [Post]
    let filteredPosts: [Post]
    let searchTerm: String
    let isDrafts: Bool
    
    var body: some View {
        if searchedPosts.isEmpty && !searchTerm.isEmpty {
            ContentUnavailableView.search
        } else if searchedPosts.isEmpty {
            ContentUnavailableView {
                Label(
                    isDrafts ? UIStrings.noDrafts : UIStrings.noPublishedPosts,
                    systemImage: isDrafts ? UIIcons.posts : UIIcons.published
                )
            }
        } else if filteredPosts.isEmpty {
            ContentUnavailableView {
                Label(UIStrings.noUnpublishedPosts, systemImage: UIIcons.published)
            }
        }
    }
}


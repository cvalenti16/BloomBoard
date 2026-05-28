//
//  PostListView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/6/25.
//

import SwiftUI
import SwiftData

struct PostListView: View {
    @AppStorage("needsOnboarding") private var needsOnboarding = true
    
    @State private var listState = ListState()
    @State private var searchTerm = ""
    
    let posts: [Post]
    
    var searchedPosts: [Post] {
        if searchTerm.isEmpty {
            return posts
        } else {
            return posts.filter { post in
                post.title.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
      
    var currentNavigationTitle: String {
        let count = searchedPosts.count
        return String(format: "%@ (%d)", "Posts", count)
    }
    
    var body: some View {
        NavigationStack(path: $listState.postDetailPath) {
            List(searchedPosts) { post in
                PostItemView(post: post) { post in
                    listState.postDetailPath.append(post)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        listState.postToDelete = post
                        listState.showDeleteAlert.toggle()
                    } label: {
                        Image(systemName: UIIcons.trash)
                            .tint(.red)
                    }
                }
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
            }
            .postDeleteAlert()
            .navigationTitle(currentNavigationTitle)
            .toolbar {
                PostListToolbar(posts: posts)
            }
        }
        .tint(.text)
        .environment(listState)
        .searchable(text: $searchTerm)
        .sheet(isPresented: $listState.showAddSheet) {
            PostEditorView(mode: .creating)
        }
//        .sheet(isPresented: $needsOnboarding) {
//            OnboardingView()
//                .interactiveDismissDisabled()
//        }
        .sheet(isPresented: $listState.showSettingsSheet) {
            SettingsView()
        }
        .overlay {
            if !searchTerm.isEmpty {
                ContentUnavailableView.search
            } else if searchedPosts.isEmpty {
                ContentUnavailableView {
                    Label("No Posts",
                          systemImage: UIIcons.posts
                    )
                }
            }
        }
    }
}

// MARK: PostListProperties
@Observable
private class ListState {
    var postDetailPath = NavigationPath()
    var postToDelete: Post?
    var showAddSheet = false
    var showSettingsSheet = false
    var showDeleteAlert = false
}

//MARK: PostItemView
struct PostItemView: View {
    let post: Post
    let onSelect: (Post) -> Void
    var hasImage: Bool {
        post.image != nil
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            
            Button {
                onSelect(post)
            } label: {
                Text(post.title)
                    .bold()
                    .font(.title3)
                    .foregroundStyle(.text)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            HStack {
                Text("\(UIStrings.created)\(post.creationDate, style: .date)")
                
                Image(systemName: hasImage ? UIIcons.photo : UIIcons.document)
                
                if post.isAITrainingPost {
                    Image(systemName: "sparkles")
                }
                
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}


// MARK: Deleting Posts
private struct PostDeleteAlert: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Environment(ListState.self) private var listState
    
    
    func body(content: Content) -> some View {
        @Bindable var listState = listState
        
        content.alert(UIStrings.deletePost, isPresented: $listState.showDeleteAlert) {
            Button(UIStrings.delete, role: .destructive) {
                if let post = listState.postToDelete {
                    modelContext.delete(post)
                    listState.postToDelete = nil
                }
            }
            Button(UIStrings.cancel, role: .cancel) {
                listState.postToDelete = nil
            }
        }
    }
}

private extension View {
    func postDeleteAlert() -> some View {
        self.modifier(PostDeleteAlert())
    }
}

// MARK: Toolbar
private struct PostListToolbar: ToolbarContent {
    @AppStorage("trackedPlatforms")
    private var platforms: String = ""
    
    @Environment(ListState.self) var listState
    let posts: [Post]
    
    
    private var primaryToolbarPlacement: ToolbarItemPlacement {
        if #available(iOS 26.0, *) {
            return .bottomBar
        } else {
            return .topBarTrailing
        }
    }

    var body: some ToolbarContent {
        @Bindable var listState = listState
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                listState.showSettingsSheet = true
            } label : {
                Image(systemName: "gearshape")
            }
        }
        
        if #available(iOS 26.0, *) {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(placement: .bottomBar)
        }
        
        ToolbarItem (placement: primaryToolbarPlacement) {
            Button(UIStrings.add, systemImage: UIIcons.add) {
                listState.showAddSheet.toggle()
            }
        }
    }
}

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
    @AppStorage("needsOnboarding") private var needsOnboarding = true
    @State private var listState = ListState()
    @State private var searchTerm = ""
    
    let posts: [Post]
    let listType: PostListType
    
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
        if let platform = listState.selectedMissingPlatform {
            return searchedPosts.filter { !($0.socialMedias?.contains(platform) ?? false)}
        } else {
            return searchedPosts
        }
    }
    
    var currentNavigationTitle: String {
        let count = filteredPosts.count
        
        switch listType {
        
        case .drafts:
            return String(format: "%@ (%d)", "Draft Posts", count)
        
        case .published:
            if let platform = listState.selectedMissingPlatform {
                return String(format: "%@ (%d)", platform.rawValue, count)
            } else {
                return String(format: "%@ (%d)", "All Published", count)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $listState.postDetailPath) {
            List(filteredPosts) { post in
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
                PostListToolbar(listType: listType)
            }
        }
        .tint(.text)
        .environment(listState)
        .searchable(text: $searchTerm)
        .sheet(isPresented: $listState.showAddSheet) {
            PostEditorView()
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $needsOnboarding) {
            OnboardingView()
                .interactiveDismissDisabled()
        }
        .overlay {
            if searchedPosts.isEmpty && !searchTerm.isEmpty {
                ContentUnavailableView.search
            } else if searchedPosts.isEmpty {
                ContentUnavailableView {
                    Label("No Avaiable Posts",
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
    var showDeleteAlert = false
    var selectedMissingPlatform: SocialMedia? = nil
}

//MARK: PostItemView
private struct PostItemView: View {
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
                if let postDate = post.postDate {
                    Text("\(UIStrings.posted)\(postDate, style: .date)")
                } else {
                    Text("\(UIStrings.created)\(post.creationDate, style: .date)")
                }
                
                Image(systemName: hasImage ? UIIcons.photo : UIIcons.document)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            if let postPerformance = post.performance {
                Text((postPerformance.rawValue))
                    .padding(5)
                    .background(postPerformance.color.opacity(0.5))
                    .clipShape(.rect(cornerRadius: 10))
                    .font(.subheadline)
            }
        }
    }
}


// MARK: PostDeleteAlert
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

// MARK: PostListToolbar
private struct PostListToolbar: ToolbarContent {
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    
    @Environment(ListState.self) var listState
    
    let listType: PostListType

    var body: some ToolbarContent {
        @Bindable var listState = listState
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
        
        switch listType {
        case .drafts:
            ToolbarItem {
                Button(UIStrings.add, systemImage: UIIcons.add) {
                    listState.showAddSheet.toggle()
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed)
            }
        case .published:
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Text(UIStrings.availableOn)
                    
                    Picker(UIStrings.availableOn, selection: $listState.selectedMissingPlatform) {
                        ForEach(SocialMedia.allCases.filter{ $0 != .none}) { platform in
                            Text(platform.rawValue).tag(platform as SocialMedia?)
                        }
                    }
                    
                    if listState.selectedMissingPlatform != nil {
                        Button(UIStrings.clear) {
                            listState.selectedMissingPlatform = nil
                        }
                    }
                } label: {
                    Label(UIStrings.filter, systemImage: UIIcons.filter)
                }
            }
        }
    }
}

enum PostListType: Equatable {
    case drafts
    case published
}

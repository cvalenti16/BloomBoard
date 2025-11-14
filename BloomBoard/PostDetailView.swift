//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var postState: PostState
    @State private var postPerformance: Performance
    let post: Post
    
    var isPosted: Bool {
        return post.postDate != nil
    }
    
    var loadedImage: UIImage? {
        guard let imageData = post.image else { return nil }
        return UIImage(data: imageData)
    }
    
    init(post: Post) {
        self.post = post
        _postState = State(initialValue: PostState())
        _postPerformance = State(initialValue: post.performance ?? Performance.unrated)
    }
    
    var body: some View {
        VStack{
            Text(post.title)
                .font(.title3)
                .bold()
                .padding(.horizontal, 10)
            
            PostDateView(postPerformance: $postPerformance, post: post)
            
            UIImageView(loadedImage: loadedImage)
            
            PostButton(isPosted)
            
            Text(postState.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postState.userFeedback)
            
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            PostDetailToolbar(post: post)
        }
        //MARK: Sheets
        .sheet(isPresented: $postState.showEditPostSheet) {
            PostEditorView(post: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postState.showPostSheet) {
            PostSheet(post: post) { closeParentSheet in
                if closeParentSheet {
                    dismiss()
                }
            }
        }
        .environment(postState)
    }
}

// MARK: Post Properties
@Observable
class PostState {
    var showEditPostSheet = false
    var showPostSheet = false
    var selectedPostDate = Date()
    var userFeedback: String? = nil
    
    func showFeedback(message: String, duration: TimeInterval = 1) {
        userFeedback = message
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.userFeedback = nil
        }
    }
}


// MARK: Post Date View
private struct PostDateView: View {
    @Environment(PostState.self) var postState
    @Binding var postPerformance: Performance
    
    let post: Post
    
    var body: some View {
        @Bindable var postState = postState
        
        VStack {
            if post.postDate != nil {
                Picker(UIStrings.performance, selection: $postPerformance) {
                    ForEach(Performance.allCases, id: \.self) { performance in
                        Text(performance.rawValue).tag(performance)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 10)
                .onChange(of: postPerformance) { _, newValue in
                    post.performance = newValue
                }
            } else {
                HStack {
                    Image(systemName: UIIcons.calendar)
                    DatePicker(
                        "",
                        selection: $postState.selectedPostDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
        }
    }
}

//MARK: UI Image View
private struct UIImageView: View {
    @Environment(PostState.self) var postState
    var loadedImage: UIImage?
    
    var body: some View {
        if let uiImage = loadedImage {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 10))
                    .padding()
                
                Button {
                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    
                    postState.showFeedback(message: FeedbackMessages.downloadSucceeded)
                    
                } label: {
                    Image(systemName: UIIcons.download)
                        .defaultIconStyle()
                }
            }
            .frame(maxHeight: 220)
        } else {
            Button {
                postState.showEditPostSheet.toggle()
            } label: {
                Image(systemName: UIIcons.upload)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(10)
            }
        }
    }
}

// MARK: Post/UnPost Button
private struct PostButton: View {
    @Environment(PostState.self) var postState
    
    let isPosted: Bool
    
    init(_ isPosted: Bool) {
        self.isPosted = isPosted
    }
    
    var body: some View {
        Button {
            postState.showPostSheet = true
        } label: {
            Text(isPosted ? UIStrings.repost : UIStrings.post)
                .defaultButtonStyle()
        }
    }
}

// MARK: Post Sheet
private struct PostSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(PostState.self) var postState
    @State private var selectedMedia: SocialMedia = .facebook
    let post: Post
    let closeParentSheet: (Bool) -> Void
    
    var isRepost: Bool {
        post.postDate != nil
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(SocialMedia.allCases.filter {
                    $0 != .none && $0 != post.originalPlatform
                }) { media in
                    Button {
                            selectedMedia = media
                    } label: {
                        HStack {
                            Text(media.rawValue)
                            
                            if isAlreadyShared(media) {
                                Image(systemName: "seal.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            if selectedMedia == media {
                                Image(systemName: isAlreadyShared(media) ? UIIcons.cancel :  UIIcons.checkmark)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .scrollDisabled(true)
                }
                
                if isRepost {
                    Button {
                        unpublishAndClose()
                    } label: {
                        Label("Unpublish" , systemImage: "arrow.uturn.left")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(UIStrings.selectPlatform)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        closeParentSheet(false)
                        postState.showPostSheet = false
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        publishAndClose()
                        
                        postState.showPostSheet = false
                    } label: {
                        Image(systemName: UIIcons.published)
                            .foregroundStyle(.text)
                    }
                }
            }
        }
    }
    
    private func isAlreadyShared(_ media: SocialMedia) -> Bool {
        post.socialMedias?.contains(media) ?? false
    }
    
    private func unpublishAndClose() {
        post.postDate = nil
        post.performance = nil
        post.socialMedias = nil
        try? modelContext.save()
        closeParentSheet(true)
        postState.showPostSheet = false
        
        post.originalPlatform = nil
    }
    
    private func publishAndClose () {
        if isAlreadyShared(selectedMedia) {
            removepost()
        } else if isRepost {
            post.socialMedias?.append(selectedMedia)
            closeParentSheet(false)
        } else {
            post.postDate = postState.selectedPostDate
            post.performance = .unrated
            post.originalPlatform = selectedMedia
            post.socialMedias = [selectedMedia]
            closeParentSheet(true)
        }
    }
    
    private func removepost() {
        if isRepost {
            post.socialMedias?.removeAll { $0 == selectedMedia }
            closeParentSheet(false)
        }
    }
}

//MARK: Toolbar
private struct PostDetailToolbar: ToolbarContent {
    @Environment(PostState.self) var postState
    
    let post: Post
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(UIStrings.copy, systemImage: UIIcons.copy) {
                UIPasteboard.general.string = post.title
                postState.showFeedback(message: FeedbackMessages.copySucceeded)
            }
        }
        
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed)
        }
        
        ToolbarItem {
            Button(UIStrings.edit, systemImage: UIIcons.edit) {
                postState.showEditPostSheet.toggle()
                
            }
        }
    }
}


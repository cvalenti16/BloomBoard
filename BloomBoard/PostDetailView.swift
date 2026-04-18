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
                .textSelection(.enabled)
                .padding(.horizontal)

            UIImageView(loadedImage: loadedImage)
            
            Text(postState.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postState.userFeedback)

            AITrainingButton(post: post)
        }
        .toolbar {
            ToolbarItem {
                Button(UIStrings.edit, systemImage: UIIcons.edit) {
                    var trans = Transaction()
                    trans.disablesAnimations = true
                    withTransaction(trans) {
                        postState.showEditPostSheet.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $postState.showEditPostSheet) {
            PostEditorView(mode: .editing(post))
        }
        .sheet(isPresented: $postState.showCropView) {
            if let image = loadedImage {
                NineBySixteenView(postImage: image)
            }
        }
        .sheet(isPresented: $postState.showPostSheet) {
            PostSheet(post: post, isPosted: isPosted) { closeParentSheet in
                if closeParentSheet {
                    dismiss()
                }
            }
        }
        .environment(postState)
    }
    
    func summaryText(_ medias: [SocialMedia]) -> String {
        let names = medias.map { $0.rawValue }
        return names.joined(separator: ", ")
    }
}

private struct AITrainingButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(PostState.self) private var postState
    
    let post: Post
    
    var body: some View {
        Button {
            updateAITrainingStatus()
        } label: {
            Text(post.isAITrainingPost ? "Remove from AI Training" : "Add to AI Training")
                .font(.headline)
                .foregroundStyle(.text)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private func updateAITrainingStatus() {
        let oldValue = post.isAITrainingPost
        post.isAITrainingPost.toggle()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            post.isAITrainingPost = oldValue
            postState.showFeedback(message: FeedbackMessages.savedFailed)
        }
    }
}

// MARK: PostState
@Observable
class PostState {
    var showEditPostSheet = false
    var showPostSheet = false
    var selectedPostDate = Date()
    var userFeedback: String? = nil
    var showCropView = false
    
    func showFeedback(message: String) {
        userFeedback = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.userFeedback = nil
        }
    }
}

// MARK: PostDateView
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
                .padding(.horizontal)
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

//MARK: UIImageView
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
                
                HStack {
                    Button {
                        postState.showCropView = true
                    } label: {
                        Image(systemName: UIIcons.portrait)
                            .defaultIconStyle()
                    }
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                        
                        postState.showFeedback(message: FeedbackMessages.downloadSucceeded)
                        
                    } label: {
                        Image(systemName: UIIcons.download)
                            .defaultIconStyle()
                    }
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
                    .padding()
            }
        }
    }
}

// MARK: PostSheet
private struct PostSheet: View {
    @AppStorage("trackedPlatforms")
    private var platforms: String = ""
    
    @Environment(\.modelContext) var modelContext
    @Environment(PostState.self) var postState
    @State private var selectedMedia: SocialMedia = .none
    
    let post: Post
    let isPosted: Bool
    let closeParentSheet: (Bool) -> Void
    
    private var trackedPlatforms: Set<SocialMedia> {
        guard !platforms.isEmpty else {
            return Set(
                SocialMedia.allCases.filter { $0 != .none }
            )
        }

        return Set(
            platforms
                .split(separator: ",")
                .compactMap { SocialMedia(rawValue: String($0)) }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(trackedPlatforms
                    .filter {$0 != post.originalPlatform}
                    .sorted {$0.rawValue < $1.rawValue}){media in
                        
                    Button {
                        selectedMedia = media
                    } label: {
                        HStack {
                            Text(media.rawValue)
                            
                            if isAlreadyShared(media) {
                                Image(systemName: UIIcons.posted)
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            if selectedMedia == media {
                                Image(systemName: isAlreadyShared(selectedMedia) ? UIIcons.cancel :  UIIcons.checkmark)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .scrollDisabled(true)
                }
                
                if isPosted {
                    Button {
                        unpublish()
                    } label: {
                        Label(UIStrings.unpublish,
                              systemImage: UIIcons.unpublished)
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
                        publish()
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
    
    private func unpublish() {
        post.postDate = nil
        post.performance = nil
        post.socialMedias = nil
        post.originalPlatform = nil
        try? modelContext.save()
        closeParentSheet(true)
        postState.showPostSheet = false
    }
    
    private func publish () {
        if isAlreadyShared(selectedMedia) {
            post.socialMedias?.removeAll { $0 == selectedMedia }
            closeParentSheet(false)
        } else if isPosted {
            post.socialMedias?.append(selectedMedia)
            closeParentSheet(false)
        } else {
            post.postDate = postState.selectedPostDate
            post.performance = .unrated
            post.originalPlatform = selectedMedia
            post.socialMedias = [selectedMedia]
            closeParentSheet(true)
        }
        try? modelContext.save()
        postState.showPostSheet = false
    }
}

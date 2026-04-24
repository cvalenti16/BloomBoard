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
    @State private var showRemix: Bool = false
    
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
            
            AITrainingButton(post: post)
            
            UIImageView(loadedImage: loadedImage)
            
            PostButton(post: post, isPosted: isPosted)
            
            Text(postState.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postState.userFeedback)
            
        }
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Remix", systemImage: "arrow.uturn.left") {
                    showRemix = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing)  {
                Button(UIStrings.edit, systemImage: UIIcons.edit) {
                    postState.showEditPostSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $postState.showEditPostSheet) {
            PostEditorView(mode: .editing(post))
        }
        .sheet(isPresented: $showRemix, content: {
            PostEditorView(mode: .remix(post))
        })
        .sheet(isPresented: $postState.showCropView) {
            if let image = loadedImage {
                NineBySixteenView(postImage: image)
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
    @Environment(\.modelContext) private var modelContext
    @Environment(PostState.self) private var postState
    
    let post: Post
    
    var body: some View {
        Toggle("AI Training", isOn: toggleBinding)
            .font(.headline)
            .foregroundStyle(.text)
            .fixedSize()
    }
    
    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { post.isAITrainingPost },
            set: { newValue in
                let oldValue = post.isAITrainingPost
                post.isAITrainingPost = newValue
                
                do {
                    try modelContext.save()
                } catch {
                    post.isAITrainingPost = oldValue
                    postState.showFeedback(message: FeedbackMessages.savedFailed)
                }
            }
        )
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

private struct PostButton: View {
    @Environment(PostState.self) var postState
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    let post: Post
    let isPosted: Bool
    
    var body: some View {
        
        if post.postDate != nil {
            Button {
                unSchedulePost()
            } label: {
                Label("Unpost",
                      systemImage: UIIcons.unpublished)
                .font(.subheadline)
                .foregroundStyle(.text)
                .opacity(0.5)
            }
        } else {
            Button {
                schedulePost()
            } label: {
                Text("Post")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding()
            }
            .buttonStyle(.plain)
        }
    }
    
    private func schedulePost() {
        post.postDate = postState.selectedPostDate
        post.performance = .unrated
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            postState.showFeedback(message: FeedbackMessages.savedFailed)
        }
    }
    
    private func unSchedulePost() {
        post.postDate = nil
        post.performance = nil
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            postState.showFeedback(message: FeedbackMessages.savedFailed)
        }
    }
}

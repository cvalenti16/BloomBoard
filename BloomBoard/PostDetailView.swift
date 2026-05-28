//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI
import SwiftData

struct PostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Query(filter: #Predicate<Post> { post in
        post.isAITrainingPost == true
    }) var aiTrainingPosts: [Post]
    
    @State private var postState: PostState
    @State private var showRemix: Bool = false
    
    let post: Post
    
    var loadedImage: UIImage? {
        guard let imageData = post.image else { return nil }
        return UIImage(data: imageData)
    }
    
    var canRemix: Bool {
        aiTrainingPosts.count > 3
    }
    
    init(post: Post) {
        self.post = post
        _postState = State(initialValue: PostState())
    }
    
    var body: some View {
        VStack{
            Text(post.title)
                .bold()
                .textSelection(.enabled)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
            
            AITrainingButton(post: post)
            
            UIImageView(loadedImage: loadedImage)
            
            Text(postState.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postState.userFeedback)
            
        }
        .toolbar {
            if canRemix {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Remix", systemImage: "arrow.triangle.2.circlepath") {
                        showRemix = true
                    }
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
            .scaleEffect(0.90)
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

//
//  EditPostSheet.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

enum EditorMode {
    case creating
    case editing(Post)
}

struct PostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<Post> { post in
            post.isAITrainingPost == true
        },
        sort: [
            SortDescriptor(\Post.creationDate, order: .reverse)
        ]) var aiTrainingPosts: [Post]
    
    @State private var title: String
    @State private var imageState: ImageState
    @State private var errorMessage: String? = nil
    @State private var titleSuggestor: TitleSuggestor?
    
    @FocusState private var isTitleFocused: Bool
    
    let mode: EditorMode
    
    private var canUseAI: Bool {
        aiTrainingPosts.count >= 5
    }
    
    var navigationTitle: String {
        switch mode {
        case .creating:
            return UIStrings.createPost
        case .editing:
            return UIStrings.editPost
        }
    }
    
    init(mode: EditorMode) {
        self.mode = mode
        let imageState = ImageState()
        
        switch mode {
        case .creating:
            _title = State(initialValue: "")
            
        case .editing(let post):
            _title = State(initialValue: post.title)
            
            if let data = post.image {
                imageState.postImage = UIImage(data: data)
            }
        }
        _imageState = State(initialValue: imageState)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Title", text: $title, axis: .vertical)
                    .padding()
                    .font(.title3)
                    .focused($isTitleFocused)
                
                ImagePreview()
                    .environment(imageState)
                
                Spacer()
                
                if let title = titleSuggestor?.title {
                        Button {
                            self.title = title
                        } label: {
                            Text(title)
                                .font(.subheadline)
                                .foregroundStyle(.text)
                        }
                }
                
                Text(errorMessage ?? "")
                    .defaultMessageStyle()
                
                HStack {
                    PhotosPicker(selection: $imageState.selectedImage, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo")
                            .foregroundStyle(.text)
                            .padding()
                        
                    }
                    .onChange(of: imageState.selectedImage) { _, newValue in
                        Task {
                            guard let data = try? await newValue?.loadTransferable(type: Data.self) else {
                                return
                            }
                            
                            await MainActor.run {
                                imageState.postImage = UIImage(data: data)
                                imageState.imageWasChanged = true
                            }
                        }
                    }
                    
                    if canUseAI, !title.isEmpty {
                        ImproveTitlesView(
                            titleSuggestor: titleSuggestor,
                            aiTrainingPosts: aiTrainingPosts,
                            postImage: imageState.postImage,
                            postTitle: title
                        )
                    }
                    
                    if canUseAI, title.isEmpty {
                        GenerateTitlesView(titleSuggestor: titleSuggestor, aiTrainingPosts: aiTrainingPosts)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        switch mode {
                        case .creating:
                            return createPost()
                        case .editing:
                            return updatePost()
                        }
                    } label: {
                        Image(systemName: UIIcons.save)
                            .foregroundStyle(.text)
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            isTitleFocused = true
        }
        .task {
            
            if canUseAI {
                titleSuggestor = TitleSuggestor()
            }
        }
    }
    
    private func updatePost() {
        guard case .editing(let post) = mode else {
            return
        }
        
        post.title = title
        
        if imageState.imageWasChanged {
            post.image = imageState.postImage?.jpegData(compressionQuality: 0.9)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = FeedbackMessages.savedFailed
        }
    }
    
    private func createPost() {
        let newPost = Post(title: title)
        
        if let imageData = imageState.postImage?.jpegData(compressionQuality: 0.9) {
            newPost.image = imageData
        }
        
        do {
            modelContext.insert(newPost)
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = FeedbackMessages.savedFailed
        }
    }
}

@Observable
class ImageState {
    var selectedImage: PhotosPickerItem? = nil
    var postImage: UIImage? = nil
    var imageWasChanged = false
}

private struct ImagePreview: View {
    @Environment(ImageState.self) var imageState
    
    var body: some View {
        if let image = imageState.postImage {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding()
                
                Button {
                    imageState.selectedImage = nil
                    imageState.postImage = nil
                    imageState.imageWasChanged = true
                } label: {
                    Image(systemName: UIIcons.trash)
                        .defaultIconStyle()
                }
                
            }
        } else {
            Text("")
                .frame(maxWidth: .infinity, maxHeight: 220)
                .padding()
        }
    }
}

struct ImproveTitlesView: View {
    let titleSuggestor: TitleSuggestor?
    let aiTrainingPosts: [Post]
    let postImage: UIImage?
    let postTitle: String
    
    var body: some View {
        switch titleSuggestor?.titlesStatus {
            
        case .fetching:
            Label("Refining title", systemImage: "sparkles")
                .symbolEffect(.pulse)
                .foregroundStyle(.text)
            
        case .success:
            Button {
                Task {
                    await titleSuggestor?.improveTitle(aiTrainingPosts, postImage, postTitle)
                }
            } label: {
                Label("Other versions", systemImage: "sparkles")
            }
            .foregroundStyle(.text)
            
        case .failed:
            Text("Error generating titles, Please try again.")
                .font(.subheadline)
                .foregroundStyle(.text)
            
        default:
            Button {
                Task {
                    await titleSuggestor?.improveTitle(aiTrainingPosts, postImage, postTitle)
                }
            } label: {
                Label("Refine title", systemImage: "sparkles")
            }
            .foregroundStyle(.text)
        }
    }
}

struct GenerateTitlesView: View {
    let titleSuggestor: TitleSuggestor?
    let aiTrainingPosts: [Post]
    
    var body: some View {
        switch titleSuggestor?.titlesStatus {
            
        case .fetching:
            Label("Generating titles", systemImage: "sparkles")
                .symbolEffect(.pulse)
                .foregroundStyle(.text)
            
        case .success:
            Button {
                Task {
                    await titleSuggestor?.generateTitles(aiTrainingPosts)
                }
            } label: {
                Label("Other titles", systemImage: "sparkles")
            }
            .foregroundStyle(.text)
            
        case .failed:
            Text("Error generating titles, Please try again.")
                .font(.subheadline)
                .foregroundStyle(.text)
            
        default:
            Button {
                Task {
                    await titleSuggestor?.generateTitles(aiTrainingPosts)
                }
            } label: {
                Label("Generate titles", systemImage: "sparkles")
            }
            .foregroundStyle(.text)
        }
    }
}

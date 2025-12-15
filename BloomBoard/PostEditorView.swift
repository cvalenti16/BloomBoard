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
    
    @State private var title: String
    @State private var imageState: ImageState
    @State private var errorMessage: String? = nil
    
    let mode: EditorMode
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
                TextField(UIStrings.title, text: $title, axis: .vertical)
                    .padding(.horizontal)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.text)
                    .frame(height: 2)
                    .padding(.horizontal)
                
                ImagePickerView(errorMessage: $errorMessage)
                    .environment(imageState)
                
                Text(errorMessage ?? "")
                    .defaultMessageStyle()
                
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

private struct ImagePickerView: View {
    @Environment(ImageState.self) var imageState
    @Binding var errorMessage: String?
    
    var body: some View {
        @Bindable var imageState = imageState
        
        PhotosPicker(selection: $imageState.selectedImage, matching: .images, photoLibrary: .shared()) {
            if let image = imageState.postImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                    
                    HStack {
                        Image(systemName: UIIcons.change)
                            .defaultIconStyle()
                        
                        Button {
                            imageState.selectedImage = nil
                            imageState.postImage = nil
                            imageState.imageWasChanged = true
                        } label: {
                            Image(systemName: UIIcons.trash)
                                .defaultIconStyle()
                        }
                    }
                }
            } else {
                Text(UIStrings.uploadImage)
                    .defaultUploadImageStyle()
            }
        }
        .onChange(of: imageState.selectedImage) { _, newValue in
            Task {
                guard let data = try? await newValue?.loadTransferable(type: Data.self) else {
                    errorMessage = FeedbackMessages.genericError
                    return
                }
                
                await MainActor.run {
                    imageState.postImage = UIImage(data: data)
                    imageState.imageWasChanged = true
                }
            }
        }
    }
}

//
//  EditPostSheet.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var imageState: ImageState
    @State private var title: String
    let post: Post?
    
    var isEditing: Bool {
        post != nil
    }
    
    init(_ post: Post? = nil) {
        self.post = post
        _title = State(initialValue: post?.title ?? "")
        
        let imageState = ImageState()
        
        if let data = post?.image {
            imageState.uiImage = UIImage(data: data)
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
                
                PhotosPicker(selection: $imageState.selectedImage, matching: .images, photoLibrary: .shared()) {
                    if let image = imageState.uiImage {
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
                                    imageState.uiImage = nil
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
                .onChange(of: imageState.selectedImage) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                imageState.uiImage = UIImage(data: data)
                                imageState.imageWasChanged = true
                            }
                        }
                    }
                }
                
                Text(imageState.errorMessage ?? "")
                    .defaultMessageStyle()
                
            }
            .navigationTitle(isEditing ? UIStrings.editPost : UIStrings.createPost)
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
                
                
            }
        }
        .environment(imageState)
    }
}

@Observable
class ImageState {
    var selectedImage: PhotosPickerItem? = nil
    var uiImage: UIImage? = nil
    var imageWasChanged = false
    var errorMessage: String? = nil
}

//MARK: PostSheetToolbar
struct PostSheetToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ImageState.self) var imageState
    
    var post: Post?
    var postTitle: String
    
    var isEditing: Bool
    
    var body: some ToolbarContent {
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
                guard !postTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    imageState.errorMessage = FeedbackMessages.emptyTitle
                    return
                }
                
                if isEditing {
                    updatePost()
                } else {
                    createPost()
                }
                
            } label: {
                Image(systemName: UIIcons.save)
                    .foregroundStyle(.text)
            }
        }
    }
}


// MARK: Create/Update Helpers
extension PostSheetToolbar {
    
    private func updatePost() {
        post?.title = postTitle
        
        if imageState.imageWasChanged {
            post?.image = imageState.uiImage?.jpegData(compressionQuality: 0.9)
        }
        
        do {
            try modelContext.save()
            
            dismiss()
        } catch {
            imageState.errorMessage = FeedbackMessages.savedFailed
        }
    }
    
    private func createPost() {
        let newPost = Post(title: postTitle)
        
        if let imageData = imageState.uiImage?.jpegData(compressionQuality: 0.9) {
            newPost.image = imageData
        }
        
        do {
            modelContext.insert(newPost)
            try modelContext.save()
            dismiss()
        } catch {
            imageState.errorMessage = FeedbackMessages.savedFailed
        }
    }
}

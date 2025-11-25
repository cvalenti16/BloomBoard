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
                PostFieldsView(title: $title)
            }
            .navigationTitle(isEditing ? UIStrings.editPost : UIStrings.createPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                PostSheetToolbar(post: post, postTitle: title, isEditing: isEditing)
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

//MARK: PostFieldsView
struct PostFieldsView: View {
    @Environment(ImageState.self) var imageState
    @Binding var title: String
     
    var body: some View {
        @Bindable var imageState = imageState
        
        VStack {
            TextField(UIStrings.title, text: $title, axis: .vertical)
                .padding(.horizontal,10)
                .bold()
            
            Rectangle()
                .foregroundStyle(.text)
                .frame(height: 2)
                .padding(.horizontal, 10)
            
            PhotosPicker(selection: $imageState.selectedImage, matching: .images, photoLibrary: .shared()) {
                if imageState.uiImage != nil {
                    ImagePreview()
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
            
            if let error = imageState.errorMessage {
                Text(error)
                    .defaultMessageStyle()
            }
        }
    }
}

//MARK: ImagePreview
struct ImagePreview: View {
    @Environment(ImageState.self) var imageState
    
    var body: some View {
        if let image = imageState.uiImage {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(10)
                
                HStack {
                    Image(systemName: UIIcons.changeIcon)
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
            }
        }
    }
}


// MARK: Create/Update Helpers
extension PostSheetToolbar {
    
    private func updatePost() {
        post?.title = postTitle
        
        if imageState.imageWasChanged {
            post?.image = imageState.uiImage?.jpegData(compressionQuality: 0.8)
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
        
        if let imageData = imageState.uiImage?.jpegData(compressionQuality: 0.8) {
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

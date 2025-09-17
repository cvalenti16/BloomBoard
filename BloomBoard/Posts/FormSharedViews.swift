//
//  ImageProperties.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/17/25.
//


import SwiftUI
import SwiftData
import PhotosUI

@Observable
class ImageProperties {
    var selectedImage: PhotosPickerItem? = nil
    var uiImage: UIImage? = nil
    var imageWasChanged = false
    var errorMessage: String? = nil
}

struct ImagePreview: View {
    @Environment(ImageProperties.self) var imageProperties
    var body: some View {
        if let image = imageProperties.uiImage {
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
                        imageProperties.selectedImage = nil
                        imageProperties.uiImage = nil
                        imageProperties.imageWasChanged = true
                    } label: {
                        Image(systemName: UIIcons.trashIcon)
                            .defaultIconStyle()
                    }
                }
            }
        } else {
            Text(PostStrings.uploadImage)
                .defaultUploadImageStyle()
        }
    }
}

//MARK: Toolbar CRUD Actions
struct PostSheetToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ImageProperties.self) var imageProperties
    
    var postTitle: String
    var post: Post?
    let isEditing: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: UIIcons.x)
                    .foregroundStyle(.text)
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                guard !postTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    imageProperties.errorMessage = FeedbackMessages.emptyTitle
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
        
        if imageProperties.imageWasChanged {
            post?.image = imageProperties.uiImage?.jpegData(compressionQuality: 0.8)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            imageProperties.errorMessage = FeedbackMessages.savedFailed
        }
    }
    
    private func createPost() {
        let newPost = Post(title: postTitle)
        
        if let imageData = imageProperties.uiImage?.jpegData(compressionQuality: 0.8) {
            newPost.image = imageData
        }
        
        do {
            modelContext.insert(newPost)
            try modelContext.save()
            dismiss()
        } catch {
            imageProperties.errorMessage = FeedbackMessages.savedFailed
        }
    }
}


//
//  EditPostSheet.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditPostSheet: View {
    @Bindable var post: Post
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var imageProperties = ImageProperties()
    @State private var draftTitle: String
    
    init(post: Post) {
        self.post = post
        _draftTitle = State(initialValue: post.title)
        
        if let data = post.image {
            imageProperties.uiImage = UIImage(data: data)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(PostStrings.enterTitle, text: $draftTitle, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.text)
                    .frame(height: 2)
                    .padding(.horizontal, 10)
                
                // MARK: Image Picker
                PhotosPicker(selection: $imageProperties.selectedImage, matching: .images, photoLibrary: .shared()) {
                    if imageProperties.uiImage != nil {
                        ImagePreview()
                            .environment(imageProperties)
                    } else {
                        Text(PostStrings.uploadImage)
                            .defaultUploadImageStyle()
                    }
                }
                .onChange(of: imageProperties.selectedImage) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                imageProperties.uiImage = UIImage(data: data)
                                imageProperties.imageWasChanged = true
                            }
                        }
                    }
                }
                
                if let error = imageProperties.errorMessage {
                    Text(error)
                        .defaultErrorStyle()
                }
            }
            .navigationTitle(PostStrings.editPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Group {
                    EditPostToolbar(draftTitle: draftTitle, post: post)
                }
            }
        }
        .environment(imageProperties)
    }
}


//MARK: Toolbar CRUD Actions
private struct EditPostToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ImageProperties.self) var imageProperties
    
    var draftTitle: String
    var post: Post

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
                guard !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    imageProperties.errorMessage = ErrorMessages.emptyTitle
                    return
                }
                
                post.title = draftTitle
                
                // update image if changed
                if imageProperties.imageWasChanged {
                    post.image = imageProperties.uiImage?.jpegData(compressionQuality: 0.8)
                }
                
                do {
                    try modelContext.save()
                    dismiss()
                } catch {
                    imageProperties.errorMessage = ErrorMessages.savedFailed
                }
                
            } label: {
                Image(systemName: UIIcons.save)
                    .defaultIconStyle()
            }
        }
    }
    
}

private struct ImagePreview: View {
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

@Observable
private class ImageProperties {
    var selectedImage: PhotosPickerItem? = nil
    var uiImage: UIImage? = nil
    var imageWasChanged = false
    var errorMessage: String? = nil
}

#Preview {
    EditPostSheet(post: .testPost)
        .preferredColorScheme(.dark)
}

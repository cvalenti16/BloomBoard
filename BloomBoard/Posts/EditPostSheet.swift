//
//  PostTitleEdit.swift
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
    
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var imageWasChanged = false
    @State private var errorMessage: String? = nil
    
    init(post: Post) {
        self.post = post

        if let data = post.image {
            _uiImage = State(initialValue: UIImage(data: data))
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Title field
                TextField("Enter title", text: $post.title, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.text)
                    .frame(height: 2)
                    .padding(.horizontal, 10)
                
                // Image picker
                PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                    if let postImage = uiImage {
                        ZStack {
                            Image(uiImage: postImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .clipShape(.rect(cornerRadius: 10))
                                .padding(10)
                            
                            HStack {
                                Image(systemName: UIIcons.changeIcon)
                                    .defaultIconStyle()
                                
                                Button {
                                    selectedImage = nil
                                    uiImage = nil
                                    imageWasChanged = true
                                } label: {
                                    Image(systemName: UIIcons.trashIcon)
                                        .defaultIconStyle()
                                }
                            }
                        }
                    } else {
                        Text(PostStrings.uploadImage)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(10)
                    }
                }
                .onChange(of: selectedImage) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                uiImage = UIImage(data: data)
                                imageWasChanged = true
                            }
                        }
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .defaultErrorStyle()
                }
                
                Spacer()
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: UIIcons.x)
                            .foregroundStyle(.text)
                    }
                }
                
                // Save
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        // update image if changed
                        if imageWasChanged {
                            if let imageData = uiImage?.jpegData(compressionQuality: 0.8) {
                                post.image = imageData
                            } else {
                                post.image = nil
                            }
                        }
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            errorMessage = ErrorMessages.savedFailed
                            print(error)
                        }
                    } label: {
                        Image(systemName: UIIcons.save)
                            .foregroundStyle(.text)
                    }
                }
            }
        }
    }
}

#Preview {
    EditPostSheet(post: .testPost)
        .preferredColorScheme(.dark)
}

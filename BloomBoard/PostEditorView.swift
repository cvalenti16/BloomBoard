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
    
    @State private var title: String
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var postImage: UIImage? = nil
    @State private var imageWasChanged = false
    @State private var errorMessage: String? = nil
    
    let post: Post?
    
    var isEditing: Bool {
        post != nil
    }
    
    init(_ post: Post? = nil) {
        self.post = post
        _title = State(initialValue: post?.title ?? "")
        
        if let data = post?.image, let image = UIImage(data: data) {
            _postImage = State(initialValue: image)
        }
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
                
                PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                    if let image = postImage {
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
                                    selectedImage = nil
                                    postImage = nil
                                    imageWasChanged = true
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
                .onChange(of: selectedImage) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                postImage = UIImage(data: data)
                                imageWasChanged = true
                            }
                        }
                    }
                }
                
                Text(errorMessage ?? "")
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
                
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if isEditing {
                            updatePost()
                        } else {
                            createPost()
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
        post?.title = title
        
        if imageWasChanged {
            post?.image = postImage?.jpegData(compressionQuality: 0.9)
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
        
        if let imageData = postImage?.jpegData(compressionQuality: 0.9) {
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


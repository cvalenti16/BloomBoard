//
//  AddPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/4/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddPostSheet: View {
    @State private var postTitle = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var imageWasChanged = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(PostStrings.title ,text: $postTitle, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.text)
                    .frame(height: 2)
                    .padding(.horizontal ,10)
                
                PhotosPicker(selection:$selectedImage, matching: .images, photoLibrary: .shared()) {
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
                .onChange(of: selectedImage) {oldValue, newValue in
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
                        .defaultMessageStyle()
                }
                
            }
            .navigationTitle(PostStrings.createPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                            errorMessage = FeedbackMessages.emptyTitle
                            return
                            
                        }
                        
                        //Create new post
                        let newPost = Post(title: postTitle)
                        
                        if let imageData = uiImage?.jpegData(compressionQuality: 0.8) {
                            newPost.image = imageData
                        }
                        
                        do {
                            modelContext.insert(newPost)
                            try modelContext.save()
                            dismiss()
                            
                        } catch {
                            errorMessage = FeedbackMessages.savedFailed
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
    AddPostSheet()
        .preferredColorScheme(.dark)
}

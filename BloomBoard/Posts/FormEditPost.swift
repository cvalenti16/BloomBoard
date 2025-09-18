//
//  EditPostSheet.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct FormEditPost: View {
    @Bindable var post: Post
    
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
                TextField(UIStrings.enterTitle, text: $draftTitle, axis: .vertical)
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
                        Text(UIStrings.uploadImage)
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
                        .defaultMessageStyle()
                }
            }
            .navigationTitle(UIStrings.editPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Group {
                    PostSheetToolbar(postTitle: draftTitle, post: post, isEditing: true)
                }
            }
        }
        .environment(imageProperties)
    }
}

#Preview {
    FormEditPost(post: .testPost)
        .preferredColorScheme(.dark)
}

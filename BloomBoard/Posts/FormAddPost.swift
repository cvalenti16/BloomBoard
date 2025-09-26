//
//  AddPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/4/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct FormAddPost: View {
    @State private var postTitle = ""
    @State private var imageProperties = ImageProperties()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(UIStrings.title ,text: $postTitle, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.text)
                    .frame(height: 2)
                    .padding(.horizontal ,10)
                
                PhotosPicker(selection:$imageProperties.selectedImage, matching: .images, photoLibrary: .shared()) {
                    if imageProperties.uiImage != nil {
                        ImagePreview()
                    } else {
                        Text(UIStrings.uploadImage)
                            .defaultUploadImageStyle()
                    }
                }
                .onChange(of: imageProperties.selectedImage) {oldValue, newValue in
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
            .navigationTitle(UIStrings.createPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                PostSheetToolbar(postTitle: postTitle, isEditing: false)
            }
        }
        .environment(imageProperties)
    }
}


#Preview {
    FormAddPost()
        .preferredColorScheme(.dark)
}

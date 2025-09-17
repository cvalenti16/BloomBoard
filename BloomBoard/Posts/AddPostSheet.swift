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
    @State private var imageProperties = ImageProperties()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    
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
                
                PhotosPicker(selection:$imageProperties.selectedImage, matching: .images, photoLibrary: .shared()) {
                    if imageProperties.uiImage != nil {
                        ImagePreview()
                            .environment(imageProperties)
                    } else {
                        Text(PostStrings.uploadImage)
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
            .navigationTitle(PostStrings.createPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Group {
                    PostSheetToolbar(postTitle: postTitle, isEditing: false)
                }
            }
        }
        .environment(imageProperties)
    }
}


#Preview {
    AddPostSheet()
        .preferredColorScheme(.dark)
}

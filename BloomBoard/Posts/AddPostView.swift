//
//  AddPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/4/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddPostView: View {
    @State private var postTitle = ""
    @State private var postImage: String? = nil
    @State private var selectedImage: PhotosPickerItem? = nil
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(PostStrings.title ,text: $postTitle, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                
                PhotosPicker(selection:$selectedImage, matching: .images, photoLibrary: .shared()) {
                    if let postImage,
                       let data = Data(base64Encoded: postImage),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(.rect(cornerRadius: 10))
                    } else {
                        Text(PostStrings.uploadImage)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .onChange(of: selectedImage) {oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            postImage = data.base64EncodedString()
                        }
                    }
                }
            }
            .navigationTitle(PostStrings.createPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(UIStrings.cancelString)
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard !postTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        let newPost = Post(title: postTitle, image: postImage)
                        modelContext.insert(newPost)
                        dismiss()
                    } label: {
                        Text(UIStrings.saveString)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    AddPostView()
        .preferredColorScheme(.dark)
}

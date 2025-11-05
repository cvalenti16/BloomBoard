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
    @State private var properties = Properties()
    @State private var title: String
    var post: Post?
   
    init(post: Post? = nil) {
        _title = State(initialValue: post?.title ?? "")
        self.post = post
        
        if let data = post?.image {
            properties.uiImage = UIImage(data: data)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                PostFieldsView(title: $title)
            }
            .navigationTitle(UIStrings.editPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                PostSheetToolbar(post: post, postTitle: title)
            }
        }
        .environment(properties)
    }
}

@Observable
class Properties {
    var selectedImage: PhotosPickerItem? = nil
    var uiImage: UIImage? = nil
    var imageWasChanged = false
    var errorMessage: String? = nil
}

struct PostFieldsView: View {
    @Environment(Properties.self) var properties
    @Binding var title: String
     
    var body: some View {
        @Bindable var properties = properties
        
        VStack {
            TextField(UIStrings.title, text: $title, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
                .bold()
            
            Rectangle()
                .foregroundStyle(.text)
                .frame(height: 2)
                .padding(.horizontal, 10)
            
            // MARK: Image Picker
            PhotosPicker(selection: $properties.selectedImage, matching: .images, photoLibrary: .shared()) {
                if properties.uiImage != nil {
                    ImagePreview()
                } else {
                    Text(UIStrings.uploadImage)
                        .defaultUploadImageStyle()
                }
            }
            .onChange(of: properties.selectedImage) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            properties.uiImage = UIImage(data: data)
                            properties.imageWasChanged = true
                        }
                    }
                }
            }
            
            if let error = properties.errorMessage {
                Text(error)
                    .defaultMessageStyle()
            }
        }
    }
}

struct ImagePreview: View {
    @Environment(Properties.self) var properties
    
    var body: some View {
        if let image = properties.uiImage {
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
                        properties.selectedImage = nil
                        properties.uiImage = nil
                        properties.imageWasChanged = true
                    } label: {
                        Image(systemName: UIIcons.trashIcon)
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

//MARK: Toolbar CRUD Actions
struct PostSheetToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(Properties.self) var properties
    
    var post: Post?
    var postTitle: String
    
    var isEditing: Bool {
        post != nil
    }
    
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
                    properties.errorMessage = FeedbackMessages.emptyTitle
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
        
        if properties.imageWasChanged {
            post?.image = properties.uiImage?.jpegData(compressionQuality: 0.8)
        }
        
        do {
            try modelContext.save()

            dismiss()
        } catch {
            properties.errorMessage = FeedbackMessages.savedFailed
        }
    }
    
    private func createPost() {
        let newPost = Post(title: postTitle)
        
        if let imageData = properties.uiImage?.jpegData(compressionQuality: 0.8) {
            newPost.image = imageData
        }
        
        do {
            modelContext.insert(newPost)
            try modelContext.save()
            dismiss()
        } catch {
            properties.errorMessage = FeedbackMessages.savedFailed
        }
    }
}



#Preview {
    PostEditorView(post: .testPost)
        .preferredColorScheme(.dark)
}

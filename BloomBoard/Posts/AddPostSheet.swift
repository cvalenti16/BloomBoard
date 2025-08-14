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
    var postToEdit: Post?
    
    @State private var postTitle = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var imageWasChanged = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    
    init(postToEdit: Post? = nil) {
        self.postToEdit = postToEdit
        _postTitle = State(initialValue: postToEdit?.title ?? "")
        
        if let filename = postToEdit?.image {
            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(filename)
            if let image = UIImage(contentsOfFile: url.path) {
                _uiImage = State(initialValue: image)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(PostStrings.title ,text: $postTitle, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.white)
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
                                Button {
                                    selectedImage = nil
                                    uiImage = nil
                                    imageWasChanged = true
                                    
                                } label: {
                                    Image(systemName: UIIcons.trashIcon)
                                        .defaultIconStyle()
                                }
                                
                                Image(systemName: UIIcons.changeIcon)
                                    .defaultIconStyle()
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
                            uiImage = UIImage(data: data)
                            imageWasChanged = true
                        }
                    }
                }
            }
            .navigationTitle(postToEdit == nil ? PostStrings.createPost : PostStrings.editPost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.x)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard !postTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                         
                        if let existingPost = postToEdit {
                            // Update existing post
                            
                            existingPost.title = postTitle
                            if imageWasChanged,let imageData = uiImage?.jpegData(compressionQuality: 0.8) {
                                existingPost.image = saveImageToDisk(imageData)
                            } else if imageWasChanged, uiImage == nil {
                                if let old = existingPost.image { deleteImageFromDisk(old)
                                }
                                
                                existingPost.image = nil
                            }
                            
                        } else {
                             //Create new post
                             var filename: String? = nil
                             if let imageData = uiImage?.jpegData(compressionQuality: 0.8) {
                                 filename = saveImageToDisk(imageData)
                             }
                             let newPost = Post(title: postTitle, image: filename)
                             modelContext.insert(newPost)
                         }
                         
                         dismiss()
                        
                    } label: {
                        Image(systemName: UIIcons.save)
                    }
                }
            }

        }

    }
    
    func saveImageToDisk(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Error saving image to disk: \(error)")
            return nil
        }
    }
    
    func deleteImageFromDisk(_ filename: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}

#Preview {
    AddPostSheet()
        .preferredColorScheme(.dark)
}

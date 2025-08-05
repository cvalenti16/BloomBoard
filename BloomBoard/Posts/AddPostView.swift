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
    @Environment(\.dismiss) var dismiss
    @State private var postTitle = ""
    @State private var postImage: String? = nil
    @State private var postCommunity = ""
    @State private var postDate = Date()
    
    @State private var selectedImage: PhotosPickerItem? = nil
    
    private var post: Post?
    
    init(post: Post? = nil) {
        _postTitle = State(initialValue: post?.title ?? "")
        _postImage = State(initialValue: post?.image ?? "")
        _postCommunity = State(initialValue: post?.community ?? "")
        _postDate = State(initialValue: post?.date ?? Date())
    }
    
    var body: some View {
        VStack {
            TextField(post?.title ?? PostStrings.title ,text: $postTitle, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
            
            TextField(post?.community ?? PostStrings.communityString, text: $postCommunity, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
            
            Text(postDate, format: .dateTime.day().month().year())
                .foregroundStyle(.gray)
            
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
        }
    }

    
    
    #Preview {
        AddPostView()
            .preferredColorScheme(.dark)
    }

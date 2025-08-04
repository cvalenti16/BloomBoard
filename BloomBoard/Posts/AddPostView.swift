//
//  AddPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/4/25.
//

import SwiftUI

struct AddPostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var postTitle = ""
    @State private var postImage = ""
    @State private var postCommunity = ""
    @State private var postDate = Date()
    
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
            
            if !postImage.isEmpty {
                Image(postImage)
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
    }
}

#Preview {
    AddPostView()
        .preferredColorScheme(.dark)
}
